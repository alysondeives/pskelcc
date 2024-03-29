/**
 * 3DConvolution.c: This file was adapted from PolyBench/GPU 1.0 test suite
 * to run on GPU with OpenMP 4.0 pragmas and OpenCL driver.
 *
<<<<<<< HEAD
 * http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU
=======
 * http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU 
>>>>>>> conflict
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
#ifdef __NVCC__
#include "jacobi3d.cuh"
#endif

// define the error threshold for the results "not matching"
#define ERROR_THRESHOLD 0.5

#define GPU_DEVICE 1
#define RADIUS 1

/* Problem size */
//#define X 512
//#define Y 512
//#define Z 512

/* Can switch DATA_TYPE between float and double */
// typedef float DATA_TYPE;

void jacobi3d(int tsteps, int x, int y, int z, DATA_TYPE *A, DATA_TYPE *B) {
    int t, i, j, k;
    DATA_TYPE c0, c1, c2, c3, c4, c5, c6;

    c0 = +1;
    c1 = +1;
    c2 = +1;
    c3 = +1;
    c4 = +1;
    c5 = +1;
    c6 = +1;

    for (t = 0; t < _PB_TSTEPS; t++) {
        for (i = 1; i < _PB_Z - 1; ++i) {
            for (j = 1; j < _PB_Y - 1; ++j) {
                for (k = 1; k < _PB_X - 1; ++k) {
                    B[i*(_PB_X * _PB_Y) + j*_PB_X + k] = c0 * A[(i  )*(_PB_X * _PB_Y) + (j  )*_PB_X + (k-1)]  +
														 c1 * A[(i  )*(_PB_X * _PB_Y) + (j  )*_PB_X + (k  )]  +
														 c2 * A[(i  )*(_PB_X * _PB_Y) + (j  )*_PB_X + (k+1)]  +
														 c3 * A[(i-1)*(_PB_X * _PB_Y) + (j  )*_PB_X + (k  )]  +
														 c4 * A[(i+1)*(_PB_X * _PB_Y) + (j  )*_PB_X + (k  )]  +
														 c5 * A[(i  )*(_PB_X * _PB_Y) + (j-1)*_PB_X + (k  )]  +
														 c6 * A[(i  )*(_PB_X * _PB_Y) + (j+1)*_PB_X + (k  )];
                }
            }
        }
        
         for (i = 1; i < _PB_Z - 1; ++i)
            for (j = 1; j < _PB_Y - 1; ++j)
                for (k = 1; k < _PB_X - 1; ++k)
                    A[i*(_PB_X * _PB_Y) + j*_PB_Z + k] = B[i*(_PB_X * _PB_Y) + j*_PB_X + k];
    }
}

void init(DATA_TYPE *A, int x, int y, int z, int offset_x, int offset_y, int offset_z) {
    int i, j, k;

    for (i = 0; i < z; ++i) {
        for (j = 0; j < y; ++j) {
            for (k = 0; k < x; ++k) {
				if (i<offset_z || j<offset_y || i>=z-offset_z || j>=y-offset_y || k<offset_x || k>=x-offset_x)
					A[i * (x * y) + j * x + k] = (DATA_TYPE) 0;
				else
					A[i * (x * y) + j * x + k] = (DATA_TYPE) 1; //i % 12 + 2 * (j % 7) + 3 * (k % 13);
				
            }
        }
    }
}

int checkResult(float *a, float *ref, int dimx, int dimy, int dimz) {

  for (int i = 0; i < dimz; i++) {
    for (int j = 0; j < dimy; j++) {
      for (int k = 0; k < dimx; k++) {
    if (a[i*dimx*dimy + j*dimx + k] != ref[i*dimx*dimy + j*dimx + k]) {
      printf("Expected: %f, received: %f at position [%d,%d,%d]\n",ref[i*dimx*dimy+j*dimx+k],a[i*dimx*dimy+j*dimx+k],i,j,k);
      //return 0;
    }
      }
    }
  }    

  return 1;

}

void compareResults(DATA_TYPE *B, DATA_TYPE *B_GPU) {
    int i, j, k, fail;
    fail = 0;

    // Compare result from cpu and gpu...
    for (i = 0; i < Z; ++i) {
        for (j = 0; j < Y; ++j) {
            for (k = 0; k < X; ++k) {
                if (percentDiff(B[i * (X * Y) + j * X + k],
                                B_GPU[i * (X * Y) + j * X + k]) >
                    ERROR_THRESHOLD) {
                    fail++;
                }
            }
        }
    }

    // Print results
    printf("Non-Matching CPU-GPU Outputs Beyond Error Threshold of %4.2f "
           "Percent: %d\n",
           ERROR_THRESHOLD, fail);
}

int main(int argc, char *argv[]) {
    /* Retrieve problem size. */
    int tsteps = TSTEPS;
    int x = X;
    int y = Y;
    int z = Z;

    double t_start, t_end;

    /* Variable declaration/allocation. */
    DATA_TYPE *A;
    DATA_TYPE *B;
    #ifdef __NVCC__
    DATA_TYPE *A_GPU_OPT;
    DATA_TYPE *B_GPU;
    DATA_TYPE *B_GPU_OPT;
	#endif
	
    A = (DATA_TYPE *)calloc((X+2*RADIUS) * (Y+2*RADIUS) * (Z+2*RADIUS), sizeof(DATA_TYPE));
    B = (DATA_TYPE *)calloc((X+2*RADIUS) * (Y+2*RADIUS) * (Z+2*RADIUS), sizeof(DATA_TYPE));
    
    #ifdef __NVCC__
    //A_GPU = (DATA_TYPE *)calloc((X+2*RADIUS) * (Y+2*RADIUS) * (Z+2*RADIUS), sizeof(DATA_TYPE));
    B_GPU = (DATA_TYPE *)calloc((X+2*RADIUS) * (Y+2*RADIUS) * (Z+2*RADIUS), sizeof(DATA_TYPE));
    A_GPU_OPT = (DATA_TYPE *)calloc((X+4*RADIUS) * (Y+4*RADIUS) * (Z+4*RADIUS), sizeof(DATA_TYPE)); 
    B_GPU_OPT = (DATA_TYPE *)calloc((X+4*RADIUS) * (Y+4*RADIUS) * (Z+4*RADIUS), sizeof(DATA_TYPE));
    #endif

    fprintf(stdout, ">> 3D 7PT Jacobi Stencil <<\n");


    init(A,X+2*RADIUS,Y+2*RADIUS,Z+2*RADIUS,RADIUS,RADIUS,RADIUS);
   
    t_start = rtclock();
    jacobi3d(tsteps, x+2*RADIUS, y+2*RADIUS, z+2*RADIUS, A, B);
    t_end = rtclock();
    fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);

    #ifdef __NVCC__
    init(A,X+2*RADIUS,Y+2*RADIUS,Z+2*RADIUS,RADIUS,RADIUS,RADIUS);
    t_start = rtclock();
    jacobi3d_GPU_baseline(tsteps, z+2*RADIUS, y+2*RADIUS, x+2*RADIUS, A, B_GPU);
    t_end = rtclock();
    fprintf(stdout, "GPU Baseline Runtime: %0.6lfs\n", t_end - t_start);
	checkResult(B_GPU,B,X+2*RADIUS, Y+2*RADIUS, Z+2*RADIUS);
    //compareResults(B, B_GPU);
	#endif 
	
	#ifdef __NVCC__
   // init(A_GPU_OPT,X+4*RADIUS,Y+4*RADIUS,Z+4*RADIUS,2*RADIUS,2*RADIUS,2*RADIUS); 
    t_start = rtclock();
   // jacobi3d_GPU_opt(tsteps, z, y, x, A_GPU_OPT, B_GPU_OPT);
    t_end = rtclock();
    fprintf(stdout, "GPU Opt Runtime: %0.6lfs\n", t_end - t_start);
   // checkResult(B_GPU_OPT,B,X,Y,Z);
    //compareResults(B, B_GPU_OPT);
	#endif 
	
    free(A);
    free(B);

    return 0;
}
