/**
 * 2mm.c: This file was adapted from PolyBench/GPU 1.0 test suite
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
//#include <omp.h>

#include "../../common/polybenchUtilFuncts.h"

//define the error threshold for the results "not matching"
#define ERROR_THRESHOLD 0.05

#define GPU_DEVICE 1

/* Problem size. */
//# define NI 1500
//# define NJ 1500
//# define NK 1500
//# define NL 1500

/* Can switch DATA_TYPE between float and double */
//typedef float DATA_TYPE;

void init_array(int ni, int nj, int nk, int nl, DATA_TYPE* A, DATA_TYPE* B, DATA_TYPE* C, DATA_TYPE* D)
{
  int i, j;

  for (i = 0; i < _PB_NI; i++)
    {
      for (j = 0; j < _PB_NK; j++)
	{
	  A[i*_PB_NI + j] = ((DATA_TYPE) i*j) / _PB_NI;
	}
    }
  
  for (i = 0; i < _PB_NK; i++)
    {
      for (j = 0; j < _PB_NJ; j++)
	{
	  B[i*_PB_NK + j] = ((DATA_TYPE) i*(j+1)) / _PB_NJ;
	}
    }
  
  for (i = 0; i < _PB_NL; i++)
    {
      for (j = 0; j < _PB_NJ; j++)
	{
	  C[i*_PB_NL + j] = ((DATA_TYPE) i*(j+3)) / _PB_NL;
	}
    }
  
  for (i = 0; i < _PB_NI; i++)
    {
      for (j = 0; j < _PB_NL; j++)
	{
	  D[i*_PB_NL + j] = ((DATA_TYPE) i*(j+2)) / _PB_NK;	
	}
    }
}

void compareResults(int ni, int nl, DATA_TYPE *E, DATA_TYPE *E_GPU)
{
  int i,j,fail;
  fail = 0;

  for (i=0; i < _PB_NL; i++)
    {
      for (j=0; j < _PB_NI; j++)
	{
	  if (percentDiff(E[i*_PB_NI + j], E_GPU[i*_PB_NI + j]) > ERROR_THRESHOLD)
	    {
	      fail++;
	    }
	}
    }
	
  // print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", ERROR_THRESHOLD, fail);
}

void mm2(int ni, int nj, int nk, int nl, DATA_TYPE* A, DATA_TYPE* B, DATA_TYPE* C, DATA_TYPE* D, DATA_TYPE* E)
{
  int i, j, k;

  for (i = 0; i < _PB_NI; i++)
    {
      for (j = 0; j < _PB_NJ; j++)
	{
	  C[i*_PB_NJ + j] = 0.0;
	  for (k = 0; k < _PB_NK; ++k)
	    {
	      C[i*_PB_NJ + j] += A[i*_PB_NK + k] * B[k*_PB_NJ + j];
	    }
	}
    }
  
    for (i = 0; i < _PB_NI; i++)
    {
      for (j = 0; j < _PB_NL; j++)
	{
	  E[i*_PB_NL + j] = 0.0;
	  for (k = 0; k < _PB_NJ; ++k)
	    {
	      E[i*_PB_NL + j] += C[i*_PB_NJ + k] * D[k*_PB_NL + j];
	    }
	}
    }
}


int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int ni = NI;
  int nj = NJ;
  int nk = NK;
  int nl = NL;

  double t_start, t_end, t_start_GPU, t_end_GPU;

  /* Variable declaration/allocation. */
  DATA_TYPE* C;
  DATA_TYPE* A;
  DATA_TYPE* B;
  DATA_TYPE* D;
  DATA_TYPE* E;

  C = (DATA_TYPE*)malloc(ni*nj*sizeof(DATA_TYPE));
  A = (DATA_TYPE*)malloc(ni*nk*sizeof(DATA_TYPE));
  B = (DATA_TYPE*)malloc(nk*nj*sizeof(DATA_TYPE));
  D = (DATA_TYPE*)malloc(nj*nl*sizeof(DATA_TYPE));
  E = (DATA_TYPE*)malloc(ni*nl*sizeof(DATA_TYPE));

  fprintf(stdout, "<< Linear Algebra: 2 Matrix Multiplications (D=A.B; E=C.D) >>\n");

  init_array(ni,nj,nk,nl,A, B, C, D);

  t_start = rtclock();
  mm2(ni,nj,nk,nl,A, B, C, D, E);
  t_end = rtclock();
  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);

  free(C);
  free(A);
  free(B);
  free(D);
  free(E);

  return 0;
}

