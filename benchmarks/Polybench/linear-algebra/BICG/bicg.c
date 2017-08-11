/**
 * bicg.c: This file was adapted from PolyBench/GPU 1.0 test suite
 * to run on GPU with OpenMP 4.0 pragmas and OpenCL driver.
 *
 * Web address: http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU
 *
 * Contacts: Marcio M Pereira <mpereira@ic.unicamp.br>
 *           Rafael Cardoso F Sousa <rafael.cardoso@students.ic.unicamp.br>
 *           Luís Felipe Mattos <ra107822@students.ic.unicamp.br>
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <sys/time.h>
//#include <omp.h>

#include "../../common/polybenchUtilFuncts.h"

//Error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.7

/* Problem size. */
//#define NX 8192
//#define NY 8192

//#define GPU_DEVICE 1

#ifndef M_PI
#define M_PI 3.14159
#endif

/* Can switch DATA_TYPE between float and double */
//typedef float DATA_TYPE;

void init_array(DATA_TYPE *A, DATA_TYPE *p, DATA_TYPE *r)
{
  int i, j;

  for (i = 0; i < NX; i++)
    {
      r[i] = i * M_PI;
      for (j = 0; j < NY; j++)
	{
	  A[i*NY + j] = ((DATA_TYPE) i*j) / NX;
	}
    }
  
  for (i = 0; i < NY; i++)
    {
      p[i] = i * M_PI;
    }
}

void compareResults(DATA_TYPE* s, DATA_TYPE* s_outputFromGpu, DATA_TYPE* q, DATA_TYPE* q_outputFromGpu)
{
  int i,fail;
  fail = 0;

  // Compare s with s_cuda
  for (i=0; i<NX; i++)
    {
      if (percentDiff(q[i], q_outputFromGpu[i]) > PERCENT_DIFF_ERROR_THRESHOLD)
	{
	  fail++;
	}
    }
  
  for (i=0; i<NY; i++)
    {
      if (percentDiff(s[i], s_outputFromGpu[i]) > PERCENT_DIFF_ERROR_THRESHOLD)
	{
	  fail++;
	}		
    }
	
  // print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", PERCENT_DIFF_ERROR_THRESHOLD, fail);
}


void bicg_cpu(int nx, int ny, DATA_TYPE* A, DATA_TYPE* r, DATA_TYPE* s, DATA_TYPE* p, DATA_TYPE* q)
{
  int i,j;
	
    for (i = 0; i < _PB_NY; i++){
        s[i] = 0.0;
    }
  
    for (i = 0; i < _PB_NX; i++){
        q[i] = 0.0;
        for (j = 0; j < _PB_NY; j++){
            s[j] = s[j] + r[i] * A[i*_PB_NY + j];
            q[i] = q[i] + p[j] * A[i*_PB_NY + j];
        }
    }
}

int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int nx = NX;
  int ny = NY;

  double t_start, t_end;

  DATA_TYPE* A;
  DATA_TYPE* r;
  DATA_TYPE* s;
  DATA_TYPE* p;
  DATA_TYPE* q;
  
  A = (DATA_TYPE*)malloc(NX*NY*sizeof(DATA_TYPE));
  r = (DATA_TYPE*)malloc(NX*sizeof(DATA_TYPE));
  s = (DATA_TYPE*)malloc(NY*sizeof(DATA_TYPE));
  p = (DATA_TYPE*)malloc(NY*sizeof(DATA_TYPE));
  q = (DATA_TYPE*)malloc(NX*sizeof(DATA_TYPE));

  fprintf(stdout, "<< BiCG Sub Kernel of BiCGStab Linear Solver >>\n");

  init_array(A, p, r);

  t_start = rtclock();
  bicg_cpu(nx, ny, A, r, s, p, q);
  t_end = rtclock();

  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);


  free(A);
  free(r);
  free(s);
  free(p);
  free(q);

  return 0;
}

