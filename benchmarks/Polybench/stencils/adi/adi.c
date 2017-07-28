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
/* Default data type is double, default size is 10x1024x1024. */
#include "adi.h"


/* Array initialization. */
void init_array (int n, DATA_TYPE* X, DATA_TYPE* A, DATA_TYPE* B) 
{
  int i, j;

  for (i = 0; i < n; i++)
    for (j = 0; j < n; j++)
      {
	X[i*N + j] = ((DATA_TYPE) i*(j+1) + 1) / n;
	A[i*N + j] = ((DATA_TYPE) i*(j+2) + 2) / n;
	B[i*N + j] = ((DATA_TYPE) i*(j+3) + 3) / n;
      }
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
void kernel_adi(int tsteps, int n, DATA_TYPE* X, DATA_TYPE* A, DATA_TYPE* B) 
{
	int t, i1, i2;

	for (t = 0; t < TMAX; t++)
	{  
		for (i1 = 0; i1 < N; i1++)
			for (i2 = 1; i2 < N; i2++)
			{
				X[i1][i2] = X[i1][i2] - X[i1][i2-1] * A[i1][i2] / B[i1][i2-1];
				B[i1][i2] = B[i1][i2] - A[i1][i2] * A[i1][i2] / B[i1][i2-1];
			}
		for (i1 = 0; i1 < N; i1++)
			X[i1][N-1] = X[i1][N-1] / B[i1][N-1];
	  
		for (i1 = 0; i1 < N; i1++)
			for (i2 = 0; i2 < N-2; i2++)
				X[i1][N-i2-2] = (X[i1][N-2-i2] - X[i1][N-2-i2-1] * A[i1][N-i2-3]) / B[i1][N-3-i2];
		for (i1 = 1; i1 < N; i1++)
			for (i2 = 0; i2 < N; i2++) {
				X[i1][i2] = X[i1][i2] - X[i1-1][i2] * A[i1][i2] / B[i1-1][i2];
				B[i1][i2] = B[i1][i2] - A[i1][i2] * A[i1][i2] / B[i1-1][i2];
			}
		  
		for (i2 = 0; i2 < N; i2++)
			X[N-1][i2] = X[N-1][i2] / B[N-1][i2];
				
		for (i1 = 0; i1 < N-2; i1++)
			for (i2 = 0; i2 < N; i2++)
				X[N-2-i1][i2] = (X[N-2-i1][i2] - X[N-i1-3][i2] * A[N-3-i1][i2]) / B[N-2-i1][i2];
	}
}

/* Main computational kernel. The whole function will be timed,
   including the call and return. */
/* Based on a Fortran code fragment from Figure 5 of
 * "Automatic Data and Computation Decomposition on Distributed Memory Parallel Computers"
 * by Peizong Lee and Zvi Meir Kedem, TOPLAS, 2002
 */
static
void kernel_adi(int tsteps, int n,
		DATA_TYPE POLYBENCH_2D(u,N,N,n,n),
		DATA_TYPE POLYBENCH_2D(v,N,N,n,n),
		DATA_TYPE POLYBENCH_2D(p,N,N,n,n),
		DATA_TYPE POLYBENCH_2D(q,N,N,n,n))
{
  int t, i, j;
  DATA_TYPE DX, DY, DT;
  DATA_TYPE B1, B2;
  DATA_TYPE mul1, mul2;
  DATA_TYPE a, b, c, d, e, f;

#pragma scop

  DX = SCALAR_VAL(1.0)/(DATA_TYPE)_PB_N;
  DY = SCALAR_VAL(1.0)/(DATA_TYPE)_PB_N;
  DT = SCALAR_VAL(1.0)/(DATA_TYPE)_PB_TSTEPS;
  B1 = SCALAR_VAL(2.0);
  B2 = SCALAR_VAL(1.0);
  mul1 = B1 * DT / (DX * DX);
  mul2 = B2 * DT / (DY * DY);

  a = -mul1 /  SCALAR_VAL(2.0);
  b = SCALAR_VAL(1.0)+mul1;
  c = a;
  d = -mul2 / SCALAR_VAL(2.0);
  e = SCALAR_VAL(1.0)+mul2;
  f = d;

 for (t=1; t<=_PB_TSTEPS; t++) {
    //Column Sweep
    for (i=1; i<_PB_N-1; i++) {
      v[0][i] = SCALAR_VAL(1.0);
      p[i][0] = SCALAR_VAL(0.0);
      q[i][0] = v[0][i];
      for (j=1; j<_PB_N-1; j++) {
        p[i][j] = -c / (a*p[i][j-1]+b);
        q[i][j] = (-d*u[j][i-1]+(SCALAR_VAL(1.0)+SCALAR_VAL(2.0)*d)*u[j][i] - f*u[j][i+1]-a*q[i][j-1])/(a*p[i][j-1]+b);
      }

      v[_PB_N-1][i] = SCALAR_VAL(1.0);
      for (j=_PB_N-2; j>=1; j--) {
        v[j][i] = p[i][j] * v[j+1][i] + q[i][j];
      }
    }
    //Row Sweep
    for (i=1; i<_PB_N-1; i++) {
      u[i][0] = SCALAR_VAL(1.0);
      p[i][0] = SCALAR_VAL(0.0);
      q[i][0] = u[i][0];
      for (j=1; j<_PB_N-1; j++) {
        p[i][j] = -f / (d*p[i][j-1]+e);
        q[i][j] = (-a*v[i-1][j]+(SCALAR_VAL(1.0)+SCALAR_VAL(2.0)*a)*v[i][j] - c*v[i+1][j]-d*q[i][j-1])/(d*p[i][j-1]+e);
      }
      u[i][_PB_N-1] = SCALAR_VAL(1.0);
      for (j=_PB_N-2; j>=1; j--) {
        u[i][j] = p[i][j] * u[i][j+1] + q[i][j];
      }
    }
  }
#pragma endscop
}


int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int n = N;
  int tsteps = TSTEPS;

  /* Variable declaration/allocation. */
  POLYBENCH_2D_ARRAY_DECL(X, DATA_TYPE, N, N, n, n);
  POLYBENCH_2D_ARRAY_DECL(A, DATA_TYPE, N, N, n, n);
  POLYBENCH_2D_ARRAY_DECL(B, DATA_TYPE, N, N, n, n);


  /* Initialize array(s). */
  init_array (n, POLYBENCH_ARRAY(X), POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));

  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  kernel_adi (tsteps, n, POLYBENCH_ARRAY(X),
	      POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(B));

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  /* Prevent dead-code elimination. All live-out data must be printed
     by the function call in argument. */
  polybench_prevent_dce(print_array(n, POLYBENCH_ARRAY(X)));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(X);
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);

  return 0;
}
