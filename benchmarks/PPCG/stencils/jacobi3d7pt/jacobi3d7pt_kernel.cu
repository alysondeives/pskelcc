#include "jacobi3d7pt_kernel.hu"
__global__ void kernel0(float *A, float *B, int n, int tsteps, int c0)
{
    int b0 = blockIdx.y, b1 = blockIdx.x;
    int t0 = threadIdx.z, t1 = threadIdx.y, t2 = threadIdx.x;

    #define ppcg_min(x,y)    ({ __typeof__(x) _x = (x); __typeof__(y) _y = (y); _x < _y ? _x : _y; })
    #define ppcg_max(x,y)    ({ __typeof__(x) _x = (x); __typeof__(y) _y = (y); _x > _y ? _x : _y; })
    for (int c1 = 32 * b0; c1 < n - 1; c1 += 8192)
      if (n >= t0 + c1 + 2 && t0 + c1 >= 1)
        for (int c2 = 32 * b1; c2 < n - 1; c2 += 8192)
          for (int c3 = 0; c3 < n - 1; c3 += 32)
            for (int c5 = ppcg_max(t1, ((t1 + c2 + 3) % 4) - c2 + 1); c5 <= ppcg_min(31, n - c2 - 2); c5 += 4)
              for (int c6 = ppcg_max(t2, ((t2 + c3 + 3) % 4) - c3 + 1); c6 <= ppcg_min(31, n - c3 - 2); c6 += 4)
                B[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6)] = ((((0.125F * ((A[((t0 + c1 + 1) * n + (c2 + c5)) * n + (c3 + c6)] + (2.F * A[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6)])) + A[((t0 + c1 - 1) * n + (c2 + c5)) * n + (c3 + c6)])) + (0.125F * ((A[((t0 + c1) * n + (c2 + c5 + 1)) * n + (c3 + c6)] + (2.F * A[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6)])) + A[((t0 + c1) * n + (c2 + c5 - 1)) * n + (c3 + c6)]))) + (0.125F * ((A[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6 + 1)] + (2.F * A[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6)])) + A[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6 - 1)]))) + (0.125F * A[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6)]));
}
__global__ void kernel1(float *A, float *B, int n, int tsteps, int c0)
{
    int b0 = blockIdx.y, b1 = blockIdx.x;
    int t0 = threadIdx.z, t1 = threadIdx.y, t2 = threadIdx.x;

    #define ppcg_min(x,y)    ({ __typeof__(x) _x = (x); __typeof__(y) _y = (y); _x < _y ? _x : _y; })
    #define ppcg_max(x,y)    ({ __typeof__(x) _x = (x); __typeof__(y) _y = (y); _x > _y ? _x : _y; })
    for (int c1 = 32 * b0; c1 < n - 1; c1 += 8192)
      if (n >= t0 + c1 + 2 && t0 + c1 >= 1)
        for (int c2 = 32 * b1; c2 < n - 1; c2 += 8192)
          for (int c3 = 0; c3 < n - 1; c3 += 32)
            for (int c5 = ppcg_max(t1, ((t1 + c2 + 3) % 4) - c2 + 1); c5 <= ppcg_min(31, n - c2 - 2); c5 += 4)
              for (int c6 = ppcg_max(t2, ((t2 + c3 + 3) % 4) - c3 + 1); c6 <= ppcg_min(31, n - c3 - 2); c6 += 4)
                A[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6)] = ((((0.125F * ((B[((t0 + c1 + 1) * n + (c2 + c5)) * n + (c3 + c6)] - (2.F * B[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6)])) + B[((t0 + c1 - 1) * n + (c2 + c5)) * n + (c3 + c6)])) + (0.125F * ((B[((t0 + c1) * n + (c2 + c5 + 1)) * n + (c3 + c6)] - (2.F * B[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6)])) + B[((t0 + c1) * n + (c2 + c5 - 1)) * n + (c3 + c6)]))) + (0.125F * ((B[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6 + 1)] - (2.F * B[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6)])) + B[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6 - 1)]))) + (0.125F * B[((t0 + c1) * n + (c2 + c5)) * n + (c3 + c6)]));
}
