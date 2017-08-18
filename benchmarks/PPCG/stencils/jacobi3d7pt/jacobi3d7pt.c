/**
 * This version is stamped on May 10, 2016
 *
 * Contact:
 *   Louis-Noel Pouchet <pouchet.ohio-state.edu>
 *   Tomofumi Yuki <tomofumi.yuki.fr>
 *
 * Web address: http://polybench.sourceforge.net
 */
/* jacobi-2d.c: this file is part of PolyBench/C */

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

/* Include polybench common header. */
#include <polybench.h>

/* Include benchmark-specific header. */
#include "../../common/common.h"


/* Array initialization. */
static
void init_array (int x,int y, int z,
		 DATA_TYPE POLYBENCH_3D(A,X,Y,Z,x,y,z),
		 DATA_TYPE POLYBENCH_3D(B,X,Y,Z,x,y,z))
{
  int i, j, k;

  for (i = 0; i < z; i++)
    for (j = 0; j < y; j++)
	  for (k = 0; k < x; k++)
      {
	A[i][j][k] = ((DATA_TYPE) 1;
	B[i][j][k] = ((DATA_TYPE) 0;
      }
}


/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(int ni, int nj, int nk,
		 DATA_TYPE POLYBENCH_3D(B,X,Y,Z,x,y,z))

{
  int i, j, k;

  for (i = 0; i < x; i++)
    for (j = 0; j < y; j++)
      for (k = 0; j < z; k++) {
	fprintf(stderr, DATA_PRINTF_MODIFIER, B[i][j][k]);
	if (((i * Y + j) * X + k) % 20 == 0) fprintf(stderr, "\n");
      }
  fprintf(stderr, "\n");
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static
void kernel_jacobi_3d(int tsteps,
			    int x,
			    int y,
			    int z,
			    DATA_TYPE POLYBENCH_3D(A,X,Y,Z,x,y,z),
			    DATA_TYPE POLYBENCH_3D(B,X,Y,Z,x,y,z))
{
  int t, i, j,k;

#pragma scop
  for (t = 0; t < _PB_TSTEPS; t++)
    {
      for (i = 1; i < _PB_Z - 1; i++)
		for (j = 1; j < _PB_X - 1; j++)
		 for (k = 1; k < _PB_Y - 1; k++)
			B[i][j][k] =  SCALAR_VAL(0.1) * A[i][j][k]
						+ SCALAR_VAL(0.1) * A[i][j][k-1]
						+ SCALAR_VAL(0.1) * A[i][j][k+1]
						+ SCALAR_VAL(0.1) * A[i][j-1][k]
						+ SCALAR_VAL(0.1) * A[i][j+1][k]
						+ SCALAR_VAL(0.1) * A[i+1][j][k]
						+ SCALAR_VAL(0.1) * A[i-1][j][k];
			             
      for (i = 1; i < _PB_Z - 1; i++)
		for (j = 1; j < _PB_Y - 1; j++)
			for (k = 1; j < _PB_X - 1; k++)
				A[i][j][k] = B[i][j][k];
    }
#pragma endscop

}


int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int x = X;
  int y = Y;
  int x = Z;
  int tsteps = TSTEPS;

  /* Variable declaration/allocation. */
  POLYBENCH_3D_ARRAY_DECL(A, DATA_TYPE, X, Y, Z, x, y, z);
  POLYBENCH_3D_ARRAY_DECL(B, DATA_TYPE, X, Y, Z, x, y, z);


  /* Initialize array(s). */
   init_array (x, y, z, POLYBENCH_ARRAY(A));

  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  kernel_jacobi_3d(tsteps, x, y, z, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  /* Prevent dead-code elimination. All live-out data must be printed
     by the function call in argument. */
  polybench_prevent_dce(print_array(x,y,z, POLYBENCH_ARRAY(B)));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);

  return 0;
}
