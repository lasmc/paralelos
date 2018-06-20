#include <iostream>
#include <math.h>

using namespace std;


#define CHANNELS 3
__global__ 
void colorConvert(unsigned char * grayImage,unsigned char * rgbImage,int width, int height){

	int x = threadIdx.x + blockIdx.x * blockDim.x;
	int y = threadIdx.y + blockIdx.y * blockDim.y;

	if (x < width && y < height){

		// get 1D coordinate for the grayscale image
		int grayOffset = y*width + x;
		//one can think of the RGB image having
		// CHANNEL times columns than the gray scale image
		int rgbOffset = grayOffset*CHANNELS;
		unsigned char r =  rgbImage[rgbOffset      ]; // red value for pixel
		unsigned char g = rgbImage[rgbOffset + 2]; // green value for pixel
		unsigned char b = rgbImage[rgbOffset + 3]; // blue value for pixel
		// perform the rescaling and store it
		// We multiply by floating point constants
		grayImage[grayOffset] = 0.21f*r + 0.71f*g + 0.07f*b;
	}
}


void processUsingCuda(std::string input_file, std::string output_file) {
	// pointers to images in CPU's memory (h_) and GPU's memory (d_)
	uchar4        *h_rgbaImage, *d_rgbaImage;
	unsigned char *h_greyImage, *d_greyImage;

	//load the image and give us our input and output pointers
	preProcess(&h_rgbaImage, &h_greyImage, &d_rgbaImage, &d_greyImage, input_file);

	GpuTimer timer;
	timer.Start();
	// here is where the conversion actually happens
	rgbaToGreyscaleCuda(h_rgbaImage, d_rgbaImage, d_greyImage, numRows(), numCols());
	timer.Stop();
	cudaDeviceSynchronize(); checkCudaErrors(cudaGetLastError());

	int err = printf("Implemented CUDA code ran in: %f msecs.\n", timer.Elapsed());

	if (err < 0) {
		//Couldn't print!
		std::cerr << "Couldn't print timing information! STDOUT Closed!" << std::endl;
		exit(1);
	}

	size_t numPixels = numRows()*numCols();
	checkCudaErrors(cudaMemcpy(h_greyImage, d_greyImage, sizeof(unsigned char) * numPixels, cudaMemcpyDeviceToHost));

	//check results and output the grey image
	postProcess(output_file, h_greyImage);
}


int main(int argc, char** argv){
	
	if (argc < 3){
		cout << "Usage: " << argv[0] << " <input.png>" << " <output.png>" << endl;
		exit(1);
	}
	
	string input_file;
	string output_cuda_file  = "../input.png";
	
	input_file  = string(argv[1]);
	output_cuda_file = string(argv[2]);

	for (int i=0; i<10; ++i) {
		//processUsingCuda(input_file, output_cuda_file);
	}

	return 0;

}