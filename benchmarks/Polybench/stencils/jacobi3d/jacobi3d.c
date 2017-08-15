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
#ifdef __NVCC__
#include "jacobi3d.cuh"
#endif

// define the error threshold for the results "not matching"
#define ERROR_THRESHOLD 0.5

#define GPU_DEVICE 1

/* Problem size */
//#define NI 512
//#define NJ 512
//#define NK 512

/* Can switch DATA_TYPE between float and double */
// typedef float DATA_TYPE;

void jacobi3d(int tsteps, int ni, int nj, int nk, DATA_TYPE *A, DATA_TYPE *B) {
    int t, i, j, k;
    DATA_TYPE c0, c1, c2, c3, c4, c5, c6;

    c0 = +2;
    c1 = +5;
    c2 = -8;
    c3 = -3;
    c4 = +6;
    c5 = -9;
    c6 = +4;

    for (t = 0; t < _PB_TSTEPS; t++) {
        for (j = 1; j < _PB_NJ - 1; ++j) {
            for (i = 1; i < _PB_NI - 1; ++i) {
                for (k = 1; k < _PB_NK - 1; ++k) {
                    B[i*(_PB_NK * _PB_NJ) + j*_PB_NK + k] = c0 * A[(i  )*(_PB_NK * _PB_NJ) + (j  )*_PB_NK + (k-1)]  +
															c1 * A[(i  )*(_PB_NK * _PB_NJ) + (j  )*_PB_NK + (k  )]  +
															c2 * A[(i  )*(_PB_NK * _PB_NJ) + (j  )*_PB_NK + (k+1)]  +
															c3 * A[(i-1)*(_PB_NK * _PB_NJ) + (j  )*_PB_NK + (k  )]  +
															c4 * A[(i+1)*(_PB_NK * _PB_NJ) + (j  )*_PB_NK + (k  )]  + //check
															c5 * A[(i  )*(_PB_NK * _PB_NJ) + (j-1)*_PB_NK + (k  )]  +
															c6 * A[(i  )*(_PB_NK * _PB_NJ) + (j+1)*_PB_NK + (k  )];
                }
            }
        }
        
         for (j = 1; j < _PB_NJ - 1; ++j)
            for (i = 1; i < _PB_NI - 1; ++i)
                for (k = 1; k < _PB_NK - 1; ++k)
                    A[i*(_PB_NK * _PB_NJ) + j*_PB_NK + k] = B[i*(_PB_NK * _PB_NJ) + j*_PB_NK + k];
    }
}

void init(DATA_TYPE *A) {
    int i, j, k;

    for (i = 0; i < NI; ++i) {
        for (j = 0; j < NJ; ++j) {
            for (k = 0; k < NK; ++k) {
                A[i * (NK * NJ) + j * NK + k] =
                    i % 12 + 2 * (j % 7) + 3 * (k % 13);
            }
        }
    }
}

void compareResults(DATA_TYPE *B, DATA_TYPE *B_GPU) {
    int i, j, k, fail;
    fail = 0;

    // Compare result from cpu and gpu...
    for (i = 1; i < NI - 1; ++i) {
        for (j = 1; j < NJ - 1; ++j) {
            for (k = 1; k < NK - 1; ++k) {
                if (percentDiff(B[i * (NK * NJ) + j * NK + k],
                                B_GPU[i * (NK * NJ) + j * NK + k]) >
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
    int ni = NI;
    int nj = NJ;
    int nk = NK;

    double t_start, t_end;

    /* Variable declaration/allocation. */
    DATA_TYPE *A;
    DATA_TYPE *B;

    A = (DATA_TYPE *)malloc(NI * NJ * NK * sizeof(DATA_TYPE));
    B = (DATA_TYPE *)malloc(NI * NJ * NK * sizeof(DATA_TYPE));

    fprintf(stdout, ">> Three dimensional (3D) convolution <<\n");

    init(A);

    t_start = rtclock();
    jacobi3d(tsteps, ni, nj, nk, A, B);
    t_end = rtclock();
    fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);
    
    t_start = rtclock();
    jacobi3D_GPU_baseline(tsteps, ni, nj, nk, A, B);
    t_end = rtclock();
    fprintf(stdout, "GPU Runtime: %0.6lfs\n", t_end - t_start);

    free(A);
    free(B);

    return 0;
}
