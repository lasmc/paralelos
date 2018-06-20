#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdlib.h>
#include <iostream>
#include "lodepng.h"
#include "lodepng.cu"

using namespace std;

__global__
void PictureKernell(unsigned char* d_Pin, unsigned char* d_Pout, int n, int m){
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int BLUR_SIZE = 25, new_pos;
    if((y < n) && (x < m)) {
        int pixValR=0, pixValB=0,pixValG=0, pixels = 0;
        int blurRow, blurCol;
        for(blurRow = -BLUR_SIZE; blurRow < BLUR_SIZE+1;++blurRow){
            for(blurCol = -BLUR_SIZE; blurCol < BLUR_SIZE+1;++blurCol){
                int curRow = y + blurRow;
                int curCol = x + blurCol;
                new_pos = (curRow*m+curCol)*4;
                if(curRow > -1 && curRow < n && curCol > -1 && curCol < m){
                    pixValR += d_Pin[new_pos];
                    pixValG += d_Pin[new_pos+1];
                    pixValB += d_Pin[new_pos+2];
                    pixels++;
                }
            }
            new_pos = (y*m+x)*4;
            d_Pout[new_pos] = (unsigned char)(pixValR/pixels);
            d_Pout[new_pos+1] = (unsigned char)(pixValG/pixels);
            d_Pout[new_pos+2] = (unsigned char)(pixValB/pixels);
            d_Pout[new_pos+3] = d_Pin[new_pos+3];
        }

    }
}

void Picture(unsigned char* Pin, unsigned char* Pout, int n, int m){
    unsigned char* d_Pout, *d_Pin;
    long int size = n*m*4;
    cudaMalloc((void **) &d_Pin,size);
    cudaMemcpy(d_Pin, Pin, size, cudaMemcpyHostToDevice);
    cudaMalloc((void **) &d_Pout,size);

    dim3 gridDim((m-1)/8+1,(n-1)/16+1,1);
    dim3 blockDim(8,16,1);
    PictureKernell<<<gridDim,blockDim>>>(d_Pin,d_Pout,n,m);

    cudaMemcpy(Pout, d_Pout, size, cudaMemcpyDeviceToHost);
    cudaFree(d_Pin); cudaFree(d_Pout);
}

int main(int argc, char * argv[] ){
    unsigned char *image, *out_image;
    int i;
    char name_in[100], name_out[100];
    unsigned width, height;

    i = lodepng_decode32_file(&image, &width, &height, name_in);
    if(i < 0) printf("NO\n");
    out_image = (unsigned char*) malloc(width*height*4);
    /*for(i = 0; i < (width * height)*4; i++){
    if(i%4==0) image[i] = 0;
    if(i%4==1) image[i] = 255;
    if(i%4==3) image[i] = 120;
    }*/
    Picture(image,out_image,height,width);
    lodepng_encode32_file(name_out,out_image,width,height);

    free(image);
    free(out_image);
    return 0;
}
