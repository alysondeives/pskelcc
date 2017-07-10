/**
 * 2DConvolution.c: This file was adapted from PolyBench/GPU 1.0 test suite
 * to run on GPU with OpenMP 4.0 pragmas and OpenCL driver.
 *
 * http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU 
 *
 * Contacts: Marcio M Pereira <mpereira@ic.unicamp.br>
 *           Rafael Cardoso F Sousa <rafael.cardoso@students.ic.unicamp.br>
 *	     Luís Felipe Mattos <ra107822@students.ic.unicamp.br>
 */

#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
//#include <omp.h>

#include "polybenchUtilFuncts.h"

//define the error threshold for the results "not matching"
#define ERROR_THRESHOLD 0.05

#define GPU_DEVICE 1

/* Problem size */
//#define NI 8192
//#define NJ 8192

#define _PB_TSTEPS 100

/* Can switch DATA_TYPE between float and double */
typedef float DATA_TYPE;
int NJ = 8192;
int NI = 8192;

void jacobi2D(DATA_TYPE* A, DATA_TYPE* B) {
    int t, i, j;
    DATA_TYPE c1;
    c1 = +0.2; 

#pragma scop
    for (t = 0; t < _PB_TSTEPS; t++) {
        for (i = 1; i < NI - 1; ++i) {
            for (j = 1; j < NJ - 1; ++j) {
	            B[i*NJ + j] = c1 * (A[(i+0)*NJ + (j - 1)] +  A[(i+0)*NJ + (j + 1)] + A[(i + 1)*NJ + (j+0)] + A[(i - 1)*NJ + (j+0)]);
	        }
        }
    
        for (i = 1; i < NI - 1; ++i) {
            for (j = 1; j < NJ - 1; ++j) {
	            A[i*NJ + j] = B[i*NJ + j];
	        }
        }
    }
#pragma endscop
}

void jacobi2Db(DATA_TYPE* A, DATA_TYPE* B, int I, int J) {
    int t, i, j;
    DATA_TYPE c1;
    c1 = +0.2; 

#pragma scop
    for (t = 0; t < _PB_TSTEPS; t++) {
        for (i = 1; i < I - 1; ++i) {
            for (j = 1; j < J - 1; ++j) {
	            B[i*J + j] = c1 * (A[J*(i) + (j - 1)] +  A[(i)*J + (j + 1)] + A[(i + 1)*J + (j)] + A[(i - 1)*J + (j)]);
	        }
        }
    
        for (i = 1; i < I - 1; ++i) {
            for (j = 1; j < J - 1; ++j) {
	            A[i*J + j] = B[i*J + j];
	        }
        }
    }
#pragma endscop
}

void jacobi1D(DATA_TYPE* A, DATA_TYPE* B, int I) {
    int t, i;
    DATA_TYPE c1;
    c1 = +0.2; 

#pragma scop
    for (t = 0; t < _PB_TSTEPS; t++) {
        for (i = 1; i < I - 1; ++i) {
	        B[i] = c1 * (A[i + 1] + A[i - 1]);
        }
    
        for (i = 1; i < I - 1; ++i) {
            A[i] = B[i];
        }
    }
#pragma endscop
}
/*
void jacobi2D_ACC(DATA_TYPE* A, DATA_TYPE* B)
{
    int t, i=1, j=1;
    DATA_TYPE c1;
    c1 = +0.2; 

    #pragma acc data copy (A[0:NI*NJ]) copyin(B[0:NI*NJ])
    {
        //#pragma acc parallel
        {
        for (t = 0; t < _PB_TSTEPS; t++) {
            #pragma acc parallel loop gang(32), vector(16)
            for (i = 1; i < NI - 1; ++i) {
                //#pragma acc loop  
                //#pragma acc cache (A[(i*NJ+j-1):3,((i-1)*NJ+ij):3])
                #pragma acc loop gang(32), vector(16)
                for (j = 1; j < NJ - 1; ++j) { 
	                B[i*NJ + j] = c1 * (A[(i + 0)*NJ + (j - 1)] +  A[(i + 0)*NJ + (j + 1)] + A[(i + 1)*NJ + (j + 0)] + A[(i - 1)*NJ + (j + 0)]);
	            }
            }

            #pragma acc parallel loop
            for (i = 1; i < NI - 1; ++i) {
                #pragma acc loop independent
                for (j = 1; j < NJ - 1; ++j) {
	                A[i*NJ + j] = B[i*NJ + j];
	            }
            }
        }
        }
   }
}
*/
/*
void conv2D_OMP(DATA_TYPE* A, DATA_TYPE* B)
{
  int i, j;
  DATA_TYPE c11, c12, c13, c21, c22, c23, c31, c32, c33;

  c11 = +0.2;  c21 = +0.5;  c31 = -0.8;
  c12 = -0.3;  c22 = +0.6;  c32 = -0.9;
  c13 = +0.4;  c23 = +0.7;  c33 = +0.10;

  #pragma omp target map(to: A[:NI*NJ]) map (from: B[:NI*NJ]) device (GPU_DEVICE)
  #pragma omp parallel for
  for (i = 1; i < NI - 1; ++i)
    {
      for (j = 1; j < NJ - 1; ++j)
	{
	  B[i*NJ + j] = c11 * A[(i - 1)*NJ + (j - 1)]  +  c12 * A[(i + 0)*NJ + (j - 1)]  +  c13 * A[(i + 1)*NJ + (j - 1)]
	    + c21 * A[(i - 1)*NJ + (j + 0)]  +  c22 * A[(i + 0)*NJ + (j + 0)]  +  c23 * A[(i + 1)*NJ + (j + 0)] 
	    + c31 * A[(i - 1)*NJ + (j + 1)]  +  c32 * A[(i + 0)*NJ + (j + 1)]  +  c33 * A[(i + 1)*NJ + (j + 1)];
	}
    }
}
*/
void init(DATA_TYPE* A, DATA_TYPE* B, DATA_TYPE *B_OMP)
{
  int i, j;

  for (i = 0; i < NI; ++i)
    {
      for (j = 0; j < NJ; ++j)
	{
	  A[i*NJ + j] = ((DATA_TYPE) i*(j+2) + 2) / NI;
	  B[i*NJ + j] = ((DATA_TYPE) i*(j+3) + 3) / NI;	
	  B_OMP[i*NJ + j] = ((DATA_TYPE) i*(j+3) + 3) / NI;	
	}
    }
}
/*
void compareResults(DATA_TYPE* B, DATA_TYPE* B_GPU)
{
  int i, j, fail;
  fail = 0;
	
  // Compare B and B_GPU
  for (i=1; i < (NI-1); i++) 
    {
      for (j=1; j < (NJ-1); j++) 
	{
	  if (percentDiff(B[i*NJ + j], B_GPU[i*NJ + j]) > ERROR_THRESHOLD) 
	    {
	      fail++;
	    }
	}
    }
	
  // Print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", ERROR_THRESHOLD, fail);
	
}
*/
int main(int argc, char *argv[])
{
  double t_start, t_end, t_start_OMP, t_end_OMP;

  DATA_TYPE* A;
  DATA_TYPE* B;  
  DATA_TYPE* B_OMP;

  NI=8192;
  NJ=8192;

  A = (DATA_TYPE*)malloc(NI*NJ*sizeof(DATA_TYPE));
  B = (DATA_TYPE*)malloc(NI*NJ*sizeof(DATA_TYPE));
  B_OMP = (DATA_TYPE*)malloc(NI*NJ*sizeof(DATA_TYPE));

  fprintf(stdout, ">> Two dimensional (2D) convolution <<\n");

  //initialize the arrays
  init(A,B,B_OMP);

  
  //t_start_OMP = rtclock();
  //jacobi2D_ACC(A, B_OMP);
  //t_end_OMP = rtclock();
  //fprintf(stdout, "GPU Runtime: %0.6lfs\n", t_end_OMP - t_start_OMP);//);
  	
  t_start = rtclock();
  jacobi2D(A, B);
  t_end = rtclock();
  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);//);
	
  //compareResults(B, B_OMP);

  free(A);
  free(B);
  free(B_OMP);
	
  return 0;
}

