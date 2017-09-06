#define BLOCK_DIMX 32
#define BLOCK_DIMY 16
#define BLOCK_DIMZ 1
#define RADIUS 1

// Error checking function
#define wbCheck(ans)                                                           \
    { gpuAssert(((cudaError_t)ans), __FILE__, __LINE__, false); }
inline void gpuAssert(cudaError_t code, const char *file, int line,
                      bool abort = false) {
    if (code != cudaSuccess) {
        fprintf(stderr, (const char *)"GPUassert: %s %s %d\n",
                cudaGetErrorString(code), file, line);
        if (abort)
            exit(code);
    }
}
__global__ void jacobi3d_kernel_baseline(int tsteps, int z, int y, int x,
                                         float *A, float *B) {
    int i = blockIdx.z * blockDim.z + threadIdx.z;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.x * blockDim.x + threadIdx.x;
    int index = (i + RADIUS) * x * y + (j + RADIUS) * x + (k + RADIUS);
    B[index] = ((((((((2 * A[index + (-1) + (y * (0))]) +
                      (5 * A[index + (0) + (y * (0))])) +
                     (-8 * A[index + (1) + (y * (0))])) +
                    (-3 * A[index + (0) + (y * (-1))])) +
                   (6 * A[index + (0) + (y * (1))])) +
                  (-9 * A[index + (0) + (y * (0))])) +
                 (4 * A[index + (0) + (y * (0))])));
}

int jacobi3d_GPU_baseline(int tsteps, int z, int y, int x, float *A, float *B) {
    float *A_GPU;
    float *B_GPU;
    size_t input_size = z * y * x * sizeof(float);
    wbCheck(cudaMalloc((void **)&A_GPU, input_size));
    wbCheck(cudaMalloc((void **)&B_GPU, input_size));
    wbCheck(cudaMemcpy(A_GPU, A, input_size, cudaMemcpyHostToDevice));
    wbCheck(cudaMemcpy(B_GPU, B, input_size, cudaMemcpyHostToDevice));
    dim3 dimBlock;
    dim3 dimGrid;
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = BLOCK_DIMZ;
    dimGrid.x = (int)ceil(x / BLOCK_DIMX);
    dimGrid.y = (int)ceil(y / BLOCK_DIMY);
    dimGrid.z = (int)ceil(z / BLOCK_DIMZ);
    for (int i = 0; i < tsteps; i++) {
        if (i % 2) {
            jacobi3d_kernel_baseline<<<dimGrid, dimBlock>>>(tsteps, z, y, x,
                                                            B_GPU, A_GPU);
        } else {
            jacobi3d_kernel_baseline<<<dimGrid, dimBlock>>>(tsteps, z, y, x,
                                                            A_GPU, B_GPU);
        }
        wbCheck(cudaGetLastError());
    }
    if ((tsteps) % 2) {
        wbCheck(cudaMemcpy(B, B_GPU, input_size, cudaMemcpyDeviceToHost));
    } else {
        wbCheck(cudaMemcpy(B, A_GPU, input_size, cudaMemcpyDeviceToHost));
    }
    wbCheck(cudaFree(A_GPU));
    wbCheck(cudaFree(B_GPU));
    return 0;
}
__global__ void jacobi3d_kernel_opt(int tsteps, int z, int y, int x, float *A,
                                    float *B) {
    __shared__ float ds_a[BLOCK_DIMY][BLOCK_DIMX];
    int j = blockIdx.y * (blockDim.y - 2 * RADIUS) + threadIdx.y + RADIUS;
    int k = blockIdx.x * (blockDim.x - 2 * RADIUS) + threadIdx.x + RADIUS;
    int in_index = j * x + k;
    int out_index = 0;
    int next_index = 0;
    int stride = x * y;
    register float t0_infront1;
    register float t1_infront1;
    register float t0_behind1;
    register float t1_behind1;
    register float t0_current;
    register float t1_current;
    in_index += RADIUS * stride;
    t0_behind1 = __ldg(&A[in_index]);
    in_index += stride;
    out_index = in_index;
    next_index = in_index;
    t0_current = __ldg(&A[in_index]);
    in_index += stride;
    t0_infront1 = __ldg(&A[in_index]);
    in_index += stride;
    if ((j >= 2 * RADIUS) && (j < (y - 2 * RADIUS)) && (k >= 2 * RADIUS) &&
        (k < (x - 2 * RADIUS))) {
        t1_current = ((((((((2 * __ldg(&A[out_index + (-1) + (y * (0))])) +
                            (5 * t0_current)) +
                           (-8 * __ldg(&A[out_index + (1) + (y * (0))]))) +
                          (-3 * __ldg(&A[out_index + (0) + (y * (-1))]))) +
                         (6 * __ldg(&A[out_index + (0) + (y * (1))]))) +
                        (-9 * t0_behind1)) +
                       (4 * t0_infront1)));
    } else {
        t1_current = t0_current;
    }
    t1_behind1 = t0_behind1;
    for (int i = 0; i < z - (4 * RADIUS); i++) {
        t0_behind1 = t0_current;
        t0_current = t0_infront1;
        t0_infront1 = __ldg(&A[in_index]);
        in_index += stride;
        next_index += stride;
        if ((j >= 2 * RADIUS) && (j < (y - 2 * RADIUS)) && (k >= 2 * RADIUS) &&
            (k < (x - 2 * RADIUS)) && (i < (z - 5 * RADIUS))) {
            t1_infront1 = ((((((((2 * __ldg(&A[out_index + (-1) + (y * (0))])) +
                                 (5 * t0_current)) +
                                (-8 * __ldg(&A[out_index + (1) + (y * (0))]))) +
                               (-3 * __ldg(&A[out_index + (0) + (y * (-1))]))) +
                              (6 * __ldg(&A[out_index + (0) + (y * (1))]))) +
                             (-9 * t0_behind1)) +
                            (4 * t0_infront1)));
        } else {
            t1_infront1 = t0_current;
        }
        __syncthreads();
        ds_a[threadIdx.y][threadIdx.x] = t1_current;
        __syncthreads();
        if ((threadIdx.y >= RADIUS) && (threadIdx.y < (BLOCK_DIMY - RADIUS)) &&
            (threadIdx.x >= RADIUS) && (threadIdx.x < (BLOCK_DIMX - RADIUS))) {
            B[out_index] =
                ((((((((2 * ds_a[threadIdx.y + (0)][threadIdx.x + (-1)]) +
                       (5 * t1_current)) +
                      (-8 * ds_a[threadIdx.y + (0)][threadIdx.x + (1)])) +
                     (-3 * ds_a[threadIdx.y + (-1)][threadIdx.x + (0)])) +
                    (6 * ds_a[threadIdx.y + (1)][threadIdx.x + (0)])) +
                   (-9 * t1_behind1)) +
                  (4 * t1_infront1)));
        }
    }
}

int jacobi3d_GPU_opt(int tsteps, int z, int y, int x, float *A, float *B) {
    float *A_GPU;
    float *B_GPU;
    size_t input_size =
        (z + 4 * RADIUS) * (y + 4 * RADIUS) * (x + 4 * RADIUS) * sizeof(float);
    wbCheck(cudaMalloc((void **)&A_GPU, input_size));
    wbCheck(cudaMalloc((void **)&B_GPU, input_size));
    wbCheck(cudaMemcpy(A_GPU, A, input_size, cudaMemcpyHostToDevice));
    wbCheck(cudaMemcpy(B_GPU, B, input_size, cudaMemcpyHostToDevice));
    dim3 dimBlock;
    dim3 dimGrid;
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(x / (BLOCK_DIMX - 2 * RADIUS));
    dimGrid.y = (int)ceil(y / (BLOCK_DIMY - 2 * RADIUS));
    dimGrid.z = 1;
    for (int i = 0; i < (tsteps / 2); i++) {
        if (i % 2) {
            jacobi3d_kernel_opt<<<dimGrid, dimBlock>>>(
                tsteps, z + 4 * RADIUS, y + 4 * RADIUS, x + 4 * RADIUS, B_GPU,
                A_GPU);
        } else {
            jacobi3d_kernel_opt<<<dimGrid, dimBlock>>>(
                tsteps, z + 4 * RADIUS, y + 4 * RADIUS, x + 4 * RADIUS, A_GPU,
                B_GPU);
        }
        wbCheck(cudaGetLastError());
    }
    if ((tsteps / 2) % 2) {
        wbCheck(cudaMemcpy(B, B_GPU, input_size, cudaMemcpyDeviceToHost));
    } else {
        wbCheck(cudaMemcpy(B, A_GPU, input_size, cudaMemcpyDeviceToHost));
    }
    wbCheck(cudaFree(A_GPU));
    wbCheck(cudaFree(B_GPU));
    return 0;
}
