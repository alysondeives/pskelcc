/* POLYBENCH/GPU-OPENACC
 *
 * This file is a part of the Polybench/GPU-OpenACC suite
 *
 * Contact:
 * William Killian <killian@udel.edu>
 * 
 * Copyright 2013, The University of Delaware
 */
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

/* Include polybench common header. */
#include "../common/polybenchUtilFuncts.h"

/* Include benchmark-specific header. */
/* Default data type is double, default size is 20x1000. */
#include "jacobi-2d.h"


/* Array initialization. */
void init_array (int n, DATA_TYPE* A, DATA_TYPE* B)
{
  int i, j;

  for (i = 0; i < n; i++)
    for (j = 0; j < n; j++)
      {
	A[i*n + j] = ((DATA_TYPE) i*(j+2) + 2) / n;
	B[i*n + j] = ((DATA_TYPE) i*(j+3) + 3) / n;
      }
}


/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(int n,
		 DATA_TYPE *A)

{
  int i, j;

  for (i = 0; i < n; i++)
    for (j = 0; j < n; j++) {
      fprintf(stderr, DATA_PRINTF_MODIFIER, A[i][j]);
      if ((i * n + j) % 20 == 0) fprintf(stderr, "\n");
    }
  fprintf(stderr, "\n");
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static
void kernel_jacobi_2d(int tsteps,
			    int n,
			    DATA_TYPE *A,
			    DATA_TYPE *B)
{
	int t, i, j;
	DATA_TYPE c1;
  
	c1 = +0.2;
	for (t = 0; t < _PB_TSTEPS; t++)
	{
		for (i = 1; i < _PB_N - 1; i++)
			for (j = 1; j < _PB_N - 1; j++)
				B[i*_PB_N + j] = c1 * (A[(i)*_PB_N + j] + A[(i)*_PB_N + (j-1)] 
				                      + A[(i)*_PB_N + (j+1)] + A[(i+1)*_PB_N + j] + A[(i-1)*_PB_N + j]);
	  
		for (i = 1; i < _PB_N-1; i++)
			for (j = 1; j < _PB_N-1; j++)
				A[i*_PB_N + j] = B[i*_PB_N + j];
    }
  }
}


int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int n = N;
  int tsteps = TSTEPS;
  
  double t_start, t_end;

  /* Variable declaration/allocation. */
  DATA_TYPE* A;
  DATA_TYPE* B;  
	
  A = (DATA_TYPE*)malloc(n*n*sizeof(DATA_TYPE));
  B = (DATA_TYPE*)malloc(n*n*sizeof(DATA_TYPE));


  /* Initialize array(s). */
  init_array (n, A, B);

  /* Start timer. */
  t_start = rtclock();

  /* Run kernel. */
  kernel_jacobi_2d (tsteps, n, A, B);

  /* Stop and print timer. */
  t_end = rtclock();
  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);

  /* Be clean. */
  free(A);
  free(B);

  return 0;
}
