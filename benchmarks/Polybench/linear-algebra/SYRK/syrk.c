/**
 * syrk.c: This file was adapted from PolyBench/GPU 1.0 test suite
 * to run on GPU with OpenMP 4.0 pragmas and OpenCL driver.
 *
 * http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU 
 *
 * Contacts: Marcio M Pereira <mpereira@ic.unicamp.br>
 *           Rafael Cardoso F Sousa <rafael.cardoso@students.ic.unicamp.br>
 *	     Luís Felipe Mattos <ra107822@students.ic.unicamp.br> 
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <unistd.h>
#include <sys/time.h>
#include "../../common/polybenchUtilFuncts.h"

//define the error threshold for the results "not matching"
#define ERROR_THRESHOLD 0.05
#define GPU_DEVICE 1

/* Problem size */
//#define N 2048
//#define M 2048

/* Declared constant values for alpha and beta */
/* (same as values in PolyBench 2.0) */
#define alpha 12435
#define beta 4546

/* Can switch DATA_TYPE between float and double */
//typedef float DATA_TYPE;

void init_arrays(DATA_TYPE* A, DATA_TYPE* C, DATA_TYPE* D) {
  int i, j;
	
  for (i = 0; i < N; i++) {
    for (j = 0; j < M; j++) {
      A[i*M + j] = ((DATA_TYPE) i*j) / N;
    }
    for (j = 0; j < M; j++) {
      C[i*M + j] = ((DATA_TYPE) i*j + 2) / N;
      D[i*M + j] = ((DATA_TYPE) i*j + 2) / N;
    }
  }
}

void compareResults(DATA_TYPE* C, DATA_TYPE* D) {
  int i,j,fail;
  fail = 0;

  // Compare C with D
  for (i=0; i<N; i++) {
    for (j=0; j<M; j++)	{
      if (percentDiff(C[i*M + j], D[i*M + j]) > ERROR_THRESHOLD) {
	fail++;
      }
    }
  }
	
  // print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", ERROR_THRESHOLD, fail);
}

void syrk(int ni, int nj, DATA_TYPE* A, DATA_TYPE* C) {
  int i, j, k;
	
    for (i = 0; i < _PB_NI; i++) {
        for (j = 0; j < _PB_NI; j++) {
            C[i*_PB_NI + j] *= beta;
        }
    }
	
    for (i = 0; i < _PB_NI; i++) {
        for (j = 0; j < _PB_NI; j++) {
            for (k = 0; k < _PB_NJ; k++) {
                C[i*_PB_NI + j] += alpha * A[i*_PB_NI + k] * A[j*_PB_NI + k];
            }
        }
    }
}

int main() {
  int ni = NI;
  int nj = NJ; 

  double t_start, t_end;

  DATA_TYPE* A;
  DATA_TYPE* C;
  DATA_TYPE* D;

  A = (DATA_TYPE*)malloc(NI*NJ*sizeof(DATA_TYPE));
  C = (DATA_TYPE*)malloc(NI*NI*sizeof(DATA_TYPE));
  D = (DATA_TYPE*)malloc(NI*NI*sizeof(DATA_TYPE));

  fprintf(stdout, "<< Symmetric rank-k operations >>\n");

  init_arrays(A, C, D);	

  t_start = rtclock();
  syrk(ni,nj, A, C);
  t_end = rtclock();
  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);

  free(A);
  free(C);
  free(D);
  return 0;
}

