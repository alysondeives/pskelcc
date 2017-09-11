/*
 * Copyright 2017, Alyson Deives Pereira
 */

#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

//#include <stdio.h>
//#include <unistd.h>
//#include <string.h>
//#include <math.h>

#define DATA_TYPE int
#define DATA_PRINTF_MODIFIER "%d"

/* Include polybench common header. */
#include "../common/common.h"

/* Array initialization. */
void init_array(int ni, int nj, DATA_TYPE *A, DATA_TYPE *B) {
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++) {
      A[i * nj + j] = ((DATA_TYPE)(i * (j + 2) + 3) % 2);
      B[i * nj + j] = ((DATA_TYPE)(i * (j + 2) + 3) % 2);
    }
}

/* Main computationaleh kernel. */
static void gol(int tsteps, int ni, int nj, DATA_TYPE *A, DATA_TYPE *B) {
  int t, i, j;
  DATA_TYPE neighbors = 0;

  for (t = 0; t < _PB_TSTEPS; t++) {
    for (i = 1; i < _PB_NI - 1; i++) {
      for (j = 1; j < _PB_NJ - 1; j++) {

        for (int y = -1; y <= 1; y++)
          for (int x = -1; x <= 1; x++)
            if (x != 0 && y != 0)
              neighbors += A[(i + y) * _PB_NJ + (j + x)];

        B[i * _PB_NJ + j] =
            (neighbors == 3 || (neighbors == 2 && A[(i)*_PB_NJ + (j)])) ? 1 : 0;
      }
    }

    for (i = 1; i < _PB_NI - 1; i++)
      for (j = 1; j < _PB_NJ - 1; j++)
        A[i * _PB_NJ + j] = B[i * _PB_NJ + j];
  }
}

int main(int argc, char **argv) {
  /* Retrieve problem size. */
  int ni = NI;
  int nj = NJ;
  int tsteps = TSTEPS;

  double t_start, t_end;

  /* Variable declaration/allocation. */
  DATA_TYPE *A;
  DATA_TYPE *B;

  A = (DATA_TYPE *)malloc(ni * nj * sizeof(DATA_TYPE));
  B = (DATA_TYPE *)malloc(ni * nj * sizeof(DATA_TYPE));

  /* Initialize array(s). */
  init_array(ni, nj, A, B);

  /* Start timer. */
  t_start = rtclock();

  /* Run kernel. */
  gol(tsteps, ni, nj, A, B);

  /* Stop and print timer. */
  t_end = rtclock();
  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);

  /* Be clean. */
  free(A);
  free(B);

  return 0;
}
