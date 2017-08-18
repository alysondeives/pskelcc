/**
 * This version is stamped on May 10, 2016
 *
 * Contact:
 *   Louis-Noel Pouchet <pouchet.ohio-state.edu>
 *   Tomofumi Yuki <tomofumi.yuki.fr>
 *
 * Web address: http://polybench.sourceforge.net
 */
#ifndef _POLYBENCH_COMMON_H
# define _POLYBENCH_COMMON_H

/* Default to LARGE_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(STANDARD_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define STANDARD_DATASET
# endif

# if !defined(TSTEPS) && !defined(N)
/* Define sample dataset sizes. */
#  ifdef MINI_DATASET
#   define TSTEPS 10
#   define X 32
#   define Y 32
#   define Z 32
#  endif

#  ifdef SMALL_DATASET
#   define TSTEPS 10
#   define N 64
#   define Y 64
#   define Z 64

#  endif

#  ifdef STANDARD_DATASET
#   define TSTEPS 10
#   define X 128
#   define Y 128
#   define Z 128
#  endif

#  ifdef LARGE_DATASET
#   define TSTEPS 10
#   define X 256
#   define Y 256
#   define Z 256
#  endif

#  ifdef EXTRALARGE_DATASET
#   define TSTEPS 10
#   define X 512
#   define Y 512
#   define Z 512
#  endif


#endif /* !(TSTEPS N) */

# define _PB_TSTEPS POLYBENCH_LOOP_BOUND(TSTEPS,tsteps)
# define _PB_X POLYBENCH_LOOP_BOUND(X,x)
# define _PB_Y POLYBENCH_LOOP_BOUND(Y,y)
# define _PB_Z POLYBENCH_LOOP_BOUND(Z,z)

/* Default data type */
# if !defined(DATA_TYPE_IS_INT) && !defined(DATA_TYPE_IS_FLOAT) && !defined(DATA_TYPE_IS_DOUBLE)
#  define DATA_TYPE_IS_FLOAT
# endif

#ifdef DATA_TYPE_IS_INT
#  define DATA_TYPE int
#  define DATA_PRINTF_MODIFIER "%d "
#endif

#ifdef DATA_TYPE_IS_FLOAT
#  define DATA_TYPE float
#  define DATA_PRINTF_MODIFIER "%0.2f "
#  define SCALAR_VAL(x) x##f
#  define SQRT_FUN(x) sqrtf(x)
#  define EXP_FUN(x) expf(x)
#  define POW_FUN(x,y) powf(x,y)
# endif

#ifdef DATA_TYPE_IS_DOUBLE
#  define DATA_TYPE double
#  define DATA_PRINTF_MODIFIER "%0.2lf "
#  define SCALAR_VAL(x) x
#  define SQRT_FUN(x) sqrt(x)
#  define EXP_FUN(x) exp(x)
#  define POW_FUN(x,y) pow(x,y)
# endif

#endif /* !_POLYBENCH_COMMON_H */
