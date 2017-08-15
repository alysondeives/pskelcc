#define BLOCK_DIMX 32
#define BLOCK_DIMY 16
#define BLOCK_DIMZ 1

__global__ void kernel_baseline(int tsteps, int nj, int ni, int nk, float *A,
                                float *B) {
    int j = BlockIdx.z * BlockDim.z + threadIdx.z;
    int i = BlockIdx.x * BlockDim.x + threadIdx.x;
    int k = BlockIdx.y * BlockDim.y + threadIdx.y;
    float tmp = A[(j + (-1)) * ni * nk + (k + (0)) * ni + (i + (0))];
    float tmp1 = A[(j + (0)) * ni * nk + (k + (0)) * ni + (i + (0))];
    float tmp6 = A[(j + (0)) * ni * nk + (k + (1)) * ni + (i + (0))];
    float tmp2 = A[(j + (1)) * ni * nk + (k + (0)) * ni + (i + (0))];
    float tmp3 = A[(j + (0)) * ni * nk + (k + (0)) * ni + (i + (-1))];
    float tmp4 = A[(j + (0)) * ni * nk + (k + (0)) * ni + (i + (1))];
    float tmp5 = A[(j + (0)) * ni * nk + (k + (-1)) * ni + (i + (0))];
    B[(j * ni * nk) + (k * ni) + (i)] =
        ((((((((2 * tmp) + (5 * tmp1)) + (-8 * tmp2)) + (-3 * tmp3)) +
            (6 * tmp4)) +
           (-9 * tmp5)) +
          (4 * tmp6)));
}
void run_baseline(int tsteps, int nj, int ni, int nk, float *A, float *B) {
    float *A_GPU;
    float *B_GPU;
    size_t input_size = nj * ni * nk * size_of(void);
    cudaMalloc((void **)&A_GPU, input_size);
    cudaMalloc((void **)&B_GPU, input_size);
    cudaMemcpy(A_GPU, A, input_size, cudaMemcpyHostToDevice);
    cudaMemcpy(B_GPU, B, input_size, cudaMemcpyHostToDevice);
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = BLOCK_DIMZ;
    dimGrid.x = (int)ceil(dimx / BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy / BLOCK_DIMY);
    dimGrid.z = (int)ceil(dimz / BLOCK_DIMZ);
    for (int i = 0; i < tsteps; i++) {
        if (i % 2) {
            kernel_baseline<<<dimGrid, dimBlock>>>(tsteps, B_GPU, A_GPU, nj, ni,
                                                   nk);
        } else {
            kernel_baseline<<<dimGrid, dimBlock>>>(tsteps, A_GPU, B_GPU, nj, ni,
                                                   nk);
        }
    }
    cudaMemcpy(B, B_GPU, input_size, cudaMemcpyDeviceToHost);
    cudaFree(A_GPU);
    cudaFree(B_GPU);
}
