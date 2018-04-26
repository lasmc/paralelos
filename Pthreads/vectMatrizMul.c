#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <sys/time.h>

double timeval_diff(struct timeval *a, struct timeval *b)
{
  return (double)(a->tv_sec + (double)a->tv_usec/1000000) - (double)(b->tv_sec + (double)b->tv_usec/1000000);
}

int thread_count,n,m;
double *matrix,*result,*vec;

void Llenarmatriz(double * matriz, int fila, int col)
{
    int i;
    for (i=0;i<(fila*col);i++) 
    {
        *(matriz + i)=1+(double)(10*random()/(RAND_MAX+1.0));
    }
    return;
}

void Mostrarmatriz(double *matriz, int fila, int col)
{
    int i,j;
    for ( i = 0; i < fila; i++) 
    {
        for (j = 0; j < col; j++) 
        {
            printf("%7g ",matriz[i*col+j]);
        }
        printf("\n");
    }
    return;
}

void* Pth_mat_vect(void* rank)
{
	long my_rank=(long) rank;
	int i,j;
	int local_m=m/thread_count;
	int my_first_row=my_rank*local_m;
	int my_last_row=(my_rank+1)*local_m -1;

	for(i=my_first_row;i<=my_last_row;i++)
	{
		result[i]=0.0;
		for(j=0;j<n;j++)
			result[i]+=matrix[i*n+j]*vec[j];
	}
	return NULL;
}

int main (int argc, char * argv[])
{
	long thread;
	pthread_t* thread_handles;
	thread_count=strtol(argv[1],NULL,10);
	thread_handles=malloc (thread_count*sizeof(pthread_t));
	m=8;
	n=8000000;
	vec=malloc(n*sizeof(double));
    result=malloc(m*sizeof(double));
    matrix=malloc(m*n*sizeof(double));
    Llenarmatriz(matrix,m,n);
    Llenarmatriz(vec,1,n);
    struct timeval t_ini, t_fin;
  	double secs;
  	gettimeofday(&t_ini, NULL);
	for (thread=0;thread<thread_count;thread++)
		pthread_create(&thread_handles[thread],NULL,Pth_mat_vect,(void*)thread);
	for (thread=0;thread<thread_count;thread++)
		pthread_join(thread_handles[thread],NULL);
	gettimeofday(&t_fin, NULL);
  	secs = timeval_diff(&t_fin, &t_ini);
  	printf("La multiplicacion toma %.3g milisegundos en ejecutarse \n", secs);
	free(thread_handles);
	free(matrix);
	free(vec);
	free(result);
	return 0;
}