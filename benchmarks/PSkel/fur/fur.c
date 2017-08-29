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
void init_array (int ni, int nj, DATA_TYPE* A, DATA_TYPE* B)
{
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++){
		A[i*nj + j] = ((DATA_TYPE) (i*(j+2) + 3) % 2);
		B[i*nj + j] = ((DATA_TYPE) (i*(j+2) + 3) % 2);
    }
}


/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(int n, DATA_TYPE *A)

{
  int i, j;

  for (i = 0; i < n; i++)
    for (j = 0; j < n; j++) {
      fprintf(stderr, DATA_PRINTF_MODIFIER, A[i*n + j]);
      if ((i * n + j) % 20 == 0) fprintf(stderr, "\n");
    }
  fprintf(stderr, "\n");
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
void fur(int tsteps, int ni, int nj, DATA_TYPE *A, DATA_TYPE *B)
{
	int t, x,y, i, j;
    DATA_TYPE numberA;
    DATA_TYPE numberI;
    
    float power;
    float totalPowerI;
    int level;
    
	for (t = 0; t < _PB_TSTEPS; t++) {
		for (i = 1; i < _PB_NI-1; i++){
			for (j = 1; j < _PB_NJ-1; j++){
				
				for (y = (level-2*level); y <= level; y++)
					for (x = (level-2*level); x <= level; x++)
							if (x != 0 || y != 0)
								numberA += A[(i+y)*_PB_NJ + (j+x)];
					
				
				for (y = (2*level-4*level); y <= 2*level; y++)
					for (x = (2*level-4*level); x <= 2*level; x++)
							if (x != 0 || y != 0)
								if (!(x <= level && x >= -1*level && y <= level && y >= -1*level))
									numberI += A[(i+y)*_PB_NJ + (j+x)];
							
				totalPowerI = numberI*power;
				B[i*_PB_NJ + j] = (numberA - totalPowerI < 0) ? 0 : ((numberA - totalPowerI > 0) ? 1 : A[i*_PB_NJ + j]);
				
				/*
				if(numberA - totalPowerI < 0)
					B[i*_PB_N + j] = 0; //without color and inhibitor
				else if(numberA - totalPowerI > 0)
					B[i*_PB_N + j] = 1;//with color and active
				else
					B[i*_PB_N + j] = input(h,w);//doesn't change
				*/					
            
			}
		}
			
		for (i = 1; i < _PB_NI-1; i++)
			for (j = 1; j < _PB_NJ-1; j++)
				A[i*_PB_NJ + j] = B[i*_PB_NJ + j];
	}
	
}

int main(int argc, char** argv){
  /* Retrieve problem size. */
  int ni = NI;
  int nj = NJ;
  int tsteps = TSTEPS;
  
  double t_start, t_end;

  /* Variable declaration/allocation. */
  DATA_TYPE* A;
  DATA_TYPE* B;  
	
  A = (DATA_TYPE*)malloc(ni*nj*sizeof(DATA_TYPE));
  B = (DATA_TYPE*)malloc(ni*nj*sizeof(DATA_TYPE));


  /* Initialize array(s). */
  init_array (ni, nj, A, B);

  /* Start timer. */
  t_start = rtclock();

  /* Run kernel. */
  fur(tsteps, ni, nj, A, B);

  /* Stop and print timer. */
  t_end = rtclock();
  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);

  /* Be clean. */
  free(A);
  free(B);

  return 0;
}
