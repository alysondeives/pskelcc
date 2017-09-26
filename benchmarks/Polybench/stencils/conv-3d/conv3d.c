/**
 * 3DConvolution.c: This file was adapted from PolyBench/GPU 1.0 test suite
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

/* Include polybench common header. */
#include "../../common/polybenchUtilFuncts.h"

/* Include benchmark-specific header. */
/* Default data type is float, default size is 256x256x256. */
//#include "conv3d.h"

//define the error threshold for the results "not matching"
#define ERROR_THRESHOLD 0.5

#define GPU_DEVICE 1

/* Problem size */
//#define W 512
//#define H 512
//#define D 512

/* Can switch DATA_TYPE between float and double */
//typedef float DATA_TYPE;

void conv3d(int x, int y, int z, DATA_TYPE* A, DATA_TYPE* B)
{
  int i, j, k;
  DATA_TYPE c11, c12, c13, c21, c22, c23, c31, c32, c33;

  c11 = +2.12345;  c21 = +5;  c31 = -8;
  c12 = -3;  c22 = +6;  c32 = -9;
  c13 = +4;  c23 = +7;  c33 = +10;

  for (j = 1; j < _PB_Y - 1; ++j){
    for (i = 1; i < _PB_X - 1; ++i){
	  for (k = 1; k < _PB_Z -1; ++k){
        B[i*(_PB_Z * _PB_Y) + j*_PB_Z + k] = c11 * A[(i-1)*(_PB_Z * _PB_Y) + (j-1)*_PB_Z + (k-1)]  +
                                             c13 * A[(i  )*(_PB_Z * _PB_Y) + (j-1)*_PB_Z + (k-1)]  +
                                             c21 * A[(i+1)*(_PB_Z * _PB_Y) + (j-1)*_PB_Z + (k-1)]  +
                                             c11 * A[(i-1)*(_PB_Z * _PB_Y) + (j-1)*_PB_Z + (k  )]  +
                                             c13 * A[(i  )*(_PB_Z * _PB_Y) + (j-1)*_PB_Z + (k  )]  +
                                             c21 * A[(i+1)*(_PB_Z * _PB_Y) + (j-1)*_PB_Z + (k  )]  + //check
                                             c11 * A[(i-1)*(_PB_Z * _PB_Y) + (j-1)*_PB_Z + (k+1)]  +
                                             c13 * A[(i  )*(_PB_Z * _PB_Y) + (j-1)*_PB_Z + (k+1)]  +
                                             c21 * A[(i+1)*(_PB_Z * _PB_Y) + (j-1)*_PB_Z + (k+1)]  + //check

                                                c11 * A[(i-1)*(_PB_Z * _PB_Y) + (j  )*_PB_Z + (k-1)]  +
                                                c13 * A[(i  )*(_PB_Z * _PB_Y) + (j  )*_PB_Z + (k-1)]  +
                                                c21 * A[(i+1)*(_PB_Z * _PB_Y) + (j  )*_PB_Z + (k-1)]  +
                                                c11 * A[(i-1)*(_PB_Z * _PB_Y) + (j  )*_PB_Z + (k  )]  + //excep
                                                c13 * A[(i  )*(_PB_Z * _PB_Y) + (j  )*_PB_Z + (k  )]  +
                                                c21 * A[(i+1)*(_PB_Z * _PB_Y) + (j  )*_PB_Z + (k  )]  +
                                                c11 * A[(i-1)*(_PB_Z * _PB_Y) + (j  )*_PB_Z + (k+1)]  +
                                                c13 * A[(i  )*(_PB_Z * _PB_Y) + (j  )*_PB_Z + (k+1)]  +
                                                c21 * A[(i+1)*(_PB_Z * _PB_Y) + (j  )*_PB_Z + (k+1)]  +
                    
                                                c11 * A[(i-1)*(_PB_Z * _PB_Y) + (j+1)*_PB_Z + (k-1)]  +
                                                c13 * A[(i  )*(_PB_Z * _PB_Y) + (j+1)*_PB_Z + (k-1)]  +
                                                c21 * A[(i+1)*(_PB_Z * _PB_Y) + (j+1)*_PB_Z + (k-1)]  +
                                                c11 * A[(i-1)*(_PB_Z * _PB_Y) + (j+1)*_PB_Z + (k  )]  +
                                                c13 * A[(i  )*(_PB_Z * _PB_Y) + (j+1)*_PB_Z + (k  )]  +
                                                c21 * A[(i+1)*(_PB_Z * _PB_Y) + (j+1)*_PB_Z + (k  )]  +
                                                c11 * A[(i-1)*(_PB_Z * _PB_Y) + (j+1)*_PB_Z + (k+1)]  +
                                                c13 * A[(i  )*(_PB_Z * _PB_Y) + (j+1)*_PB_Z + (k+1)]  +
                                                c21 * A[(i+1)*(_PB_Z * _PB_Y) + (j+1)*_PB_Z + (k+1)];
        }
	}
    }
}

void init(DATA_TYPE* A)
{
  int i, j, k;
  
  for (i = 0; i < X; ++i)
    {
      for (j = 0; j < Y; ++j)
	{
	  for (k = 0; k < Z; ++k)
	    {
	      A[i*(Z * Y) + j*Z + k] = i % 12 + 2 * (j % 7) + 3 * (k % 13);
	    }
	}
    }
}

void compareResults(DATA_TYPE* B, DATA_TYPE* B_GPU)
{
  int i, j, k, fail;
  fail = 0;
  
  // Compare result from cpu and gpu...
  for (i = 1; i < X - 1; ++i)
    {
      for (j = 1; j < Y - 1; ++j)
	{
	  for (k = 1; k < Z - 1; ++k)
	    {
	      if (percentDiff(B[i*(Z * Y) + j*Z + k], B_GPU[i*(Z * Y) + j*Z + k]) > ERROR_THRESHOLD)
		{
		  fail++;
		}
	    }	
	}
    }
  
  // Print results
  printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f Percent: %d\n", ERROR_THRESHOLD, fail);
}

int main(int argc, char *argv[])
{
  /* Retrieve problem size. */
  int x = X;
  int y = Y;
  int z = Z;
  
  double t_start, t_end;

  /* Variable declaration/allocation. */
  DATA_TYPE* A;
  DATA_TYPE* B;

  A = (DATA_TYPE*)malloc(X*Y*Z*sizeof(DATA_TYPE));
  B = (DATA_TYPE*)malloc(X*Y*Z*sizeof(DATA_TYPE));
	
  fprintf(stdout, ">> Three dimensional (3D) convolution <<\n");

  init(A);

  t_start = rtclock();
  conv3d(x, y, z, A, B);
  t_end = rtclock();
  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);
	

  free(A);
  free(B);

  return 0;
}
