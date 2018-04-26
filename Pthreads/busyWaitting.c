#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <unistd.h>

int thread_count, flag, n;
double sum;

void * thread_sum(void * rank)
{
	long my_rank = (long) rank;
	double factor;
	double my_sum = 0.0;
	long long i;
	long long my_n = n/thread_count;
	long long my_first_i = my_n * my_rank;
	long long my_last_i = my_first_i + my_n;

	if(my_first_i%2 == 0)
	{
		factor = 1.0;
	}else{
		factor = -1.0;
	}

	for(i = my_first_i; i < my_last_i; i++, factor = -factor)
	{
		my_sum += factor/(2*i+1);
	}

	while(flag != my_rank);
	printf("Thread %ld de %d la suma aqui es %7g\n", my_rank, thread_count, my_sum);
	sum+=my_sum;	
	flag=(flag+1)%thread_count;
	return NULL;
}

int main(int argc, char *argv[])
{
	long thread;
	pthread_t* thread_handles;
	thread_count = strtol(argv[1],NULL,10);
	thread_handles = malloc (thread_count*sizeof(pthread_t));
	flag=0;
	sum=0;
	n=108;
	clock_t t;
	
	t = clock();
	for (thread = 0; thread < thread_count; thread++)
	{
		pthread_create(&thread_handles[thread],NULL,thread_sum,(void*)thread);
	}

	printf("Thread principal\n");
	for (thread = 0; thread < thread_count; thread++)
	{
		pthread_join(thread_handles[thread],NULL);
	}
	t = clock() - t;
	free(thread_handles);
	printf ("La suma total es: %7g\n",sum);
	printf ("Esto toma %f seconds.\n",((float)t)/CLOCKS_PER_SEC);
	return 0;
}