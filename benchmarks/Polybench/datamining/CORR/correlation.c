/**
 * correlation.c This file was adapted from PolyBench/GPU 1.0 test suite
 * to run on GPU with OpenMP 4.0 pragmas and OpenCL driver.
 *
 * Web address: http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU
 *
 * Contacts: Marcio M Pereira <mpereira@ic.unicamp.br>
 *           Rafael Cardoso F Sousa <rafael.cardoso@students.ic.unicamp.br>
 *  	     Luís Felipe Mattos <ra107822@students.ic.unicamp.br>
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <sys/time.h>
//#include <omp.h>

#include "../../common/polybenchUtilFuncts.h"

//define the error threshold for the results "not matching"
#define ERROR_THRESHOLD 1.05

#define GPU_DEVICE 1

/* Problem size */
#define M 2048
#define N 2048

#define sqrt_of_array_cell(x,j) sqrt(x[j])

#define FLOAT_N 3214212.01f
#define EPS 0.005f

/* Can switch DATA_TYPE between float and double */
typedef float DATA_TYPE;

void init_arrays(DATA_TYPE* data)
{
  int i, j;
	
  for (i=0; i < (M+1); i++) 
    {
      for (j=0; j< (N+1); j++) 
	{
	  data[i*(N+1) + j] = ((DATA_TYPE) i*j)/ (M+1);	
	}
    }
}

void correlation(int m, int n, DATA_TYPE* data, DATA_TYPE* mean, DATA_TYPE* stddev, DATA_TYPE* symmat)
{
  int i, j, j1, j2;	
	
    // Determine mean of column vectors of input data matrix 
    for (j = 0; j < _PB_M; j++){
        mean[j] = 0.0;
        for (i = 0; i < _PB_N; i++){
            mean[j] += data[i*_PB_M + j];
        }
		
        mean[j] /= (DATA_TYPE)FLOAT_N;
    }

    // Determine standard deviations of column vectors of data matrix. 
    for (j = 0; j < _PB_M; j++){
        stddev[j] = 0.0;
      
        for (i = 0; i < _PB_N; i++){
            stddev[j] += (data[i*_PB_M + j] - mean[j]) * (data[i*_PB_M + j] - mean[j]);
        }
		
        stddev[j] /= FLOAT_N;
        stddev[j] = sqrt_of_array_cell(stddev, j);
        stddev[j] = stddev[j] <= EPS ? 1.0 : stddev[j];
    }

    // Center and reduce the column vectors. 
    for (i = 0; i < _PB_N; i++){
      for (j = 0; j < _PB_M; j++){
        data[i*_PB_M + j] -= mean[j];
        data[i*_PB_M + j] /= (sqrt(FLOAT_N)*stddev[j]) ;
        }
    }

    // Calculate the m * m correlation matrix. 
    for (j1 = 0; j1 < _PB_M-1; j1++){	
        symmat[j1*_PB_M + j1] = 1.0;
      
        for (j2 = j1+1; j2 < _PB_M; j2++){
            symmat[j1*_PB_M + j2] = 0.0;
	  
            for (i = 0; i < _PB_N; i++){
                symmat[j1*_PB_M + j2] += (data[i*_PB_M + j1] * data[i*_PB_M + j2]);
            }
	  
            symmat[j2*_PB_M + j1] = symmat[j1*_PB_M + j2];
        }
    }
 
  symmat[(_PB_M-1)*(_PB_M) + (_PB_M-1)] = 1.0;

}

void compareResults(DATA_TYPE* symmat, DATA_TYPE* symmat_outputFromGpu)
{
  int i,j,fail;
  fail = 0;

  for (i=1; i < (M+1); i++)
    {
      for (j=1; j < (N+1); j++)
	{
	  if (percentDiff(symmat[i*(N+1) + j], symmat_outputFromGpu[i*(N+1) + j]) > ERROR_THRESHOLD)
	    {
	      fail++;
	      //printf("i: %d j: %d\n1: %f 2: %f\n", i, j, symmat[i*N + j], symmat_GPU[i*N + j]);		
	    }
	}
    }
	
  // print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", ERROR_THRESHOLD, fail);
}

int main()
{
  double t_start, t_end;

  /* Retrieve problem size. */
  int n = N;
  int m = M;

  DATA_TYPE* data;
  DATA_TYPE* mean;
  DATA_TYPE* stddev;
  DATA_TYPE* symmat;

  data = (DATA_TYPE*)malloc((M+1)*(N+1)*sizeof(DATA_TYPE));
  mean = (DATA_TYPE*)malloc((M+1)*sizeof(DATA_TYPE));
  stddev = (DATA_TYPE*)malloc((M+1)*sizeof(DATA_TYPE));
  symmat = (DATA_TYPE*)malloc((M+1)*(N+1)*sizeof(DATA_TYPE));

  fprintf(stdout, "<< Correlation Computation >>\n");

  init_arrays(data);

  t_start = rtclock();
  correlation(m,n,data, mean, stddev, symmat);
  t_end = rtclock();

  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);

  free(data);
  free(mean);
  free(stddev);
  free(symmat);
  
  return 0;
}


