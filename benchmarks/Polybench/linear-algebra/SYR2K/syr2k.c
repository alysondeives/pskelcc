/**
 * syr2k.c: This file was adapted from PolyBench/GPU 1.0 test suite
 * to run on GPU with OpenMP 4.0 pragmas and OpenCL driver.
 *
 * http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU 
 *
 * Contacts: Marcio M Pereira <mpereira@ic.unicamp.br>
 *           Rafael Cardoso F Sousa <rafael.cardoso@students.ic.unicamp.br>
 *           Luís Felipe Mattos <ra107822@students.ic.unicamp.br> 
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <unistd.h>
#include <sys/time.h>
//#include <omp.h>

#include "../../common/polybenchUtilFuncts.h"

//define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.10

/* Problem size */
//#define N 2048
//#define M 2048

#define GPU_DEVICE 1

/* Declared constant values for ALPHA and BETA (same as values in PolyBench 2.0) */
#define ALPHA 12435
#define BETA 4546

/* Can switch DATA_TYPE between float and double */
//typedef float DATA_TYPE;

void init_arrays(DATA_TYPE *A, DATA_TYPE *B, DATA_TYPE *C)
{
  int i, j;
  
  for (i = 0; i < N; i++)
    {
      for (j = 0; j < N; j++)
	{
	  C[i*N + j] = ((DATA_TYPE) i*j + 2) / N;
	}
      	
      for (j = 0; j < M; j++)
	{
	  A[i*N + j] = ((DATA_TYPE) i*j) / N;
	  B[i*N + j] = ((DATA_TYPE) i*j + 1) / N;
	}
    }
}

void syr2k(int ni, int nj, DATA_TYPE *A, DATA_TYPE *B, DATA_TYPE *C)
{
  int i, j, k;
		
    for (i = 0; i < _PB_NI; i++){  
        for (j = 0; j < _PB_NI; j++){
            C[i*_PB_NI + j] *= BETA;
        }
    }

    for (i = 0; i < _PB_NI; i++){
        for (j = 0; j < _PB_NI; j++){
            for (k = 0; k < _PB_NJ; k++){
                C[i*_PB_NI + j] += ALPHA * A[i*_PB_NJ + k] * B[j*_PB_NI + k];
                C[i*_PB_NI + j] += ALPHA * B[i*_PB_NI + k] * A[j*_PB_NI + k];
            }
        }
    }
}

void compareResults(DATA_TYPE *C, DATA_TYPE *C_Gpu){
  int i,j,fail;
  fail = 0;

  // Compare C with D
  for (i=0; i<N; i++)
    {
      for (j=0; j<N; j++)
	{
	  if (percentDiff(C[i*N + j], C_Gpu[i*N + j]) > PERCENT_DIFF_ERROR_THRESHOLD)
	    { 
	      fail++;
	    }
	}
    }
	
  // print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", PERCENT_DIFF_ERROR_THRESHOLD, fail);
}

int main()
{
  int ni = NI;
  int nj = NJ;

  double t_start, t_end;

  DATA_TYPE* A;
  DATA_TYPE* B;
  DATA_TYPE* C;

  A = (DATA_TYPE*)malloc(NI*NJ*sizeof(DATA_TYPE));
  B = (DATA_TYPE*)malloc(NI*NJ*sizeof(DATA_TYPE));
  C = (DATA_TYPE*)malloc(NI*NI*sizeof(DATA_TYPE));

  fprintf(stdout, "<< Symmetric rank-2k operations >>\n");

  init_arrays(A, B, C);

  t_start = rtclock();
  syr2k(ni,nj,A, B, C);
  t_end = rtclock();
  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);


  free(A);
  free(B);
  free(C);
  
  return 0;
}

