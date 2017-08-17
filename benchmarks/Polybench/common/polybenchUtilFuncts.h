//polybenchUtilFuncts.h
//Scott Grauer-Gray (sgrauerg@gmail.com)
//Functions used across hmpp codes

#ifndef POLYBENCH_UTIL_FUNCTS_H
#define POLYBENCH_UTIL_FUNCTS_H

//define a small float value
#define SMALL_FLOAT_VAL 0.00000001f

# ifndef DATA_TYPE
#  define DATA_TYPE float
#  define DATA_PRINTF_MODIFIER "%0.2lf "
# endif

/* Default to LARGE_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(MEDIUM_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define STANDARD_DATASET
# endif

// Defines used per benchmark:
//
// H		[conv3d, jacobi3d]
// W		[conv3d, jacobi3d]
// D		[conv3d, jacobi3d]
// N        [adi, cholesky, correlation, covariance, floyd-warshall, jacobi-2d-imper, lu, ludcmp, seidel-2d]
// M        [correlation, covariance]
// NI       [2mm, 3mm, fdtd-2d, gemm, symm, syrk, syr2k, trmm]
// NJ       [2mm, 3mm, fdtd-2d, gemm, symm, syrk, syr2k]
// NK       [2mm, 3mm, gemm]
// NL       [2mm, 3mm]
// NQ       [doitgen]
// NR       [doitgen]
// NP       [doitgen]
// NM       [3mm]
// NX       [atax, bicg, durbin, gemver, gesummv, mvt, trisolv]
// NY       [atax, bicg]
// CZ       [fdtd-2d-apml]
// CYM      [fdtd-2d-apml]
// CXM      [fdtd-2d-apml]
// LARGE_N  [jacobi-1d-imper]
// LENGTH   [dynprog, reg_detect]
// TSTEPS   [adi, fdtd-2d, jacobi-1d-imper, jacobi-2d-imper, seidel-2d]
// ITER     [dynprog, reg_detect]
// MAXGRID  [reg_detect]
//

// Determine the sizes of the 5 possible datasets
#ifdef MINI_DATASET
	#define X 64
	#define Y 64 
	#define Z 64
	#define N 32
	#define M 32
	#define NI 32
	#define NJ 32
	#define NK 32
	#define NL 32
	#define NM 32
	#define NQ 10
	#define NR 10
	#define NP 10
	#define NX 32
	#define NY 32
	#define CZ 32
	#define CYM 32
	#define CXM 32
	#define LARGE_N 500
	#define LENGTH 32
	#define TSTEPS 2
	#define ITER 10
	#define MAXGRID 2
#endif
#ifdef SMALL_DATASET
	#define X 128
	#define Y 128
	#define Z 128
	#define N 256
	#define M 256
	#define NI 128
	#define NJ 128
	#define NK 128
	#define NL 128
	#define NM 128
	#define NQ 32
	#define NR 32
	#define NP 32
	#define NX 500
	#define NY 500
	#define CZ 64
	#define CYM 64
	#define CXM 64
	#define LARGE_N 1000
	#define LENGTH 50
	#define TSTEPS 2
	#define ITER 2
	#define MAXGRID 8
#endif
#ifdef STANDARD_DATASET
	#define X 192
	#define Y 192 
	#define Z 192
	#define N 1024
	#define M 1024
	#define NI 1024
	#define NJ 1024
	#define NK 1024
	#define NL 1024
	#define NM 1024
	#define NQ 128
	#define NR 128
	#define NP 128
	#define NX 4000
	#define NY 4000
	#define CZ 256
	#define CYM 256
	#define CXM 256
	#define LARGE_N 10000
	#define LENGTH 50
	#define TSTEPS 2
	#define ITER 10
	#define MAXGRID 32
#endif
#ifdef LARGE_DATASET
	#define X 256
	#define Y 246
	#define Z 256
	#define N 2048
	#define M 2048
	#define NI 2048
	#define NJ 2048
	#define NK 2048
	#define NL 2048
	#define NM 2048
	#define NQ 256
	#define NR 256
	#define NP 256
	#define NX 4096
	#define NY 4096
	#define CZ 512
	#define CYM 512
	#define CXM 512
	#define LARGE_N 2048*2048
	#define LENGTH 500
	#define TSTEPS 5
	#define ITER 100
	#define MAXGRID 128
#endif
#ifdef EXTRALARGE_DATASET
	#define X 384
	#define Y 384
	#define Z 384
	#define N 4000
	#define M 4000
	#define NI 4000
	#define NJ 4000
	#define NK 4000
	#define NL 4000
	#define NM 4000
	#define NQ 1000
	#define NR 1000
	#define NP 1000
	#define NX 100000
	#define NY 100000
	#define CZ 1000
	#define CYM 1000
	#define CXM 1000
	#define LARGE_N 10000000
	#define LENGTH 500
	#define TSTEPS 10
	#define ITER 1000
	#define MAXGRID 512
#endif

# define _PB_X POLYBENCH_LOOP_BOUND(X,x)
# define _PB_Y POLYBENCH_LOOP_BOUND(Y,y)
# define _PB_Z POLYBENCH_LOOP_BOUND(Z,z)
# define _PB_M POLYBENCH_LOOP_BOUND(M,m)
# define _PB_N POLYBENCH_LOOP_BOUND(N,n)
# define _PB_NI POLYBENCH_LOOP_BOUND(NI,ni)
# define _PB_NJ POLYBENCH_LOOP_BOUND(NJ,nj)
# define _PB_NK POLYBENCH_LOOP_BOUND(NK,nk)
# define _PB_NL POLYBENCH_LOOP_BOUND(NL,nl)
# define _PB_NM POLYBENCH_LOOP_BOUND(NM,nm)
# define _PB_NQ POLYBENCH_LOOP_BOUND(NQ,nq)
# define _PB_NR POLYBENCH_LOOP_BOUND(NR,nr)
# define _PB_NP POLYBENCH_LOOP_BOUND(NP,np)
# define _PB_NX POLYBENCH_LOOP_BOUND(NX,nx)
# define _PB_NY POLYBENCH_LOOP_BOUND(NY,ny)
# define _PB_CZ POLYBENCH_LOOP_BOUND(CZ,cz)
# define _PB_CYM POLYBENCH_LOOP_BOUND(CYM,cym)
# define _PB_CXM POLYBENCH_LOOP_BOUND(CXM,cxm)
# define _PB_TSTEPS POLYBENCH_LOOP_BOUND(TSTEPS,tsteps)
# define _PB_ITER POLYBENCH_LOOP_BOUND(ITER,iter)

/* Scalar loop bounds in SCoPs. By default, use parametric loop bounds. */
# ifdef POLYBENCH_USE_SCALAR_LB
#  define POLYBENCH_LOOP_BOUND(x,y) x
# else
/* default: */
#  define POLYBENCH_LOOP_BOUND(x,y) y
# endif

double rtclock()
{
    struct timezone Tzp;
    struct timeval Tp;
    int stat;
    stat = gettimeofday (&Tp, &Tzp);
    if (stat != 0) printf("Error return from gettimeofday: %d",stat);
    return(Tp.tv_sec + Tp.tv_usec*1.0e-6);
}


float absVal(float a)
{
	if(a < 0)
	{
		return (a * -1);
	}
   	else
	{ 
		return a;
	}
}



float percentDiff(double val1, double val2)
{
	if ((absVal(val1) < 0.01) && (absVal(val2) < 0.01))
	{
		return 0.0f;
	}

	else
	{
    		return 100.0f * (absVal(absVal(val1 - val2) / absVal(val1 + SMALL_FLOAT_VAL)));
	}
} 

#endif //POLYBENCH_UTIL_FUNCTS_H
