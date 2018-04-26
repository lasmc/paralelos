#include <mpi.h>
#include <stdio.h>
 
int main (int argc, char* argv[])
{
	int rank, size, state;
	int bold = 0;

	MPI_Init (&argc, &argv);      /* starts MPI */
  	MPI_Comm_rank (MPI_COMM_WORLD, &rank);        /* get current process id */
  	MPI_Comm_size (MPI_COMM_WORLD, &size);        /* get number of processes */

  	state = rank;
  	while(bold <10)
  	{
  		if(state==0)
  		{
  			bold +=1;
  			printf( "Enviando..... %d a %d\n", rank, bold);
  			MPI_Send(&bold, 4, MPI_INT, (rank+1)%2, 0, MPI_COMM_WORLD);
  			state = 1;	
  		}else{
  			MPI_Recv(&bold, 4, MPI_INT, (rank+1)%2, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
  			state = 0;
  		}
  	}
  	MPI_Finalize();
  	return 0;
} 