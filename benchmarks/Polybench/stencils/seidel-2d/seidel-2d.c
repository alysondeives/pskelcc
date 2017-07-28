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
#include "seidel-2d.h"


/* Array initialization. */
void init_array (int n, DATA_TYPE *A)
{
  int i, j;

  for (i = 0; i < n; ++i)
    for (j = 0; j < n; ++j)
      A[i*n + j] = ((DATA_TYPE) i*(j+2) + 2) / n;
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
void kernel_seidel_2d(int tsteps, int n, DATA_TYPE *A)
{
	int t, i, j;

	for (t = 0; t <= _PB_TSTEPS - 1; t++)
		for (i = 1; i<= _PB_N - 2; i++)
			for (j = 1; j <= _PB_N - 2; j++)
				 A[i*N + j] = (A[(i - 1)*_PB_N + (j - 1)] + A[(i + 0)*_PB_N + (j - 1)] +  A[(i + 1)*_PB_N + (j - 1)]
							 + A[(i - 1)*_PB_N + (j + 0)] + A[(i + 0)*_PB_N + (j + 0)] +  A[(i + 1)*_PB_N + (j + 0)] 
							 + A[(i - 1)*_PB_N + (j + 1)] + A[(i + 0)*_PB_N + (j + 1)] +  A[(i + 1)*_PB_N + (j + 1)])/9.0;

}


int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int n = N;
  int tsteps = TSTEPS;

  /* Variable declaration/allocation. */
  DATA_TYPE* A;
  A = (DATA_TYPE*)malloc(n*n*sizeof(DATA_TYPE));

  /* Initialize array(s). */
  init_array (n, A);

  /* Start timer. */
  t_start = rtclock();

  /* Run kernel. */
  kernel_seidel_2d (tsteps, n, POLYBENCH_ARRAY(A));

  /* Stop and print timer. */
  t_end = rtclock();
  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);

  /* Be clean. */
  free(A);

  return 0;
}
