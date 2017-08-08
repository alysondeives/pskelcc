/* Available optimizations (value should be used as the first parameter in the command line):
   0 (o0) -> no optimization
   1 (o1) -> shared memory
   2 (o2) -> for iteration on Z axis (Paulius)
   3 (o3) -> for iteration on Z axis without using registers
   25 (o2_o5) -> for iteration on Z axis (Paulius) + pragma unroll
   12 (o1_o2) -> shared memory + for iteration on Z axis
   13 (o1_o3) -> shared memory + for iteration on Z axis without registers
   124 (o1_o2_o4) -> shared memory + for iteration on Z axis + temporal blocking
   125 (o1_o2_o5) -> shared memory + for iteration on Z axis + pragma unroll
   7 (o7) -> use of read only cache (__restrict__ and const modifiers)
   17 (o1_o7) -> use of shared memory + read only cache (__restrict__ and const modifiers)
   27 (o2_o7) -> for iteration on Z axis + read only cache
   37 (o3_o7) -> for iteration on Z axis without registers + read only cache
   1247 (o1_o2_o4_o7) -> shared memory + read only cache + for iteration on Z axis + temporal blocking

   Known limitations: data matrix size must be multiple of BLOCK_SIZE
*/

#include <stdio.h>

//#define PRINT_GOLD
//#define PRINT_RESULT

#define BLOCK_DIMX 32
#define BLOCK_DIMY 16
#define BLOCK_DIMZ 1
#define RADIUS 1 // Half of the order

// Uncomment the following line to enable inside kernel run time measurement
//#define MEASURE_KERNEL_RUNTIME

// Error checking function
#define wbCheck(stmt) do {                                                    \
        cudaError_t err = stmt;                                               \
        if (err != cudaSuccess) {                                             \
            printf("ERROR: Failed to run stmt %s\n", #stmt);                       \
            printf("ERROR: Got CUDA error ...  %s\n", cudaGetErrorString(err));    \
            return -1;                                                        \
        }                                                                     \
    } while(0)

// Elapsed clock cycles read function
#ifdef MEASURE_KERNEL_RUNTIME
#define read_clk_cycles(var,tindex) if ( (row == tindex) && (col == tindex) && (depth == tindex) ) { \
                                       var = clock64();						     \
                                    }
#else
#define read_clk_cycles(var,tindex)
#endif


__constant__ float coeff[RADIUS*6+1];

/* 
   Optimization o0: baseline code (no optimization)
*/
__global__ void calc_stencil_o0(float *a, float *b, int dimx, int dimy) {

  int tx = threadIdx.x;
  int ty = threadIdx.y;
  int tz = threadIdx.z;
	
  int row = blockIdx.y * blockDim.y + ty;
  int col = blockIdx.x * blockDim.x + tx;
  int depth = blockIdx.z * blockDim.z + tz;
	
  // (depth/row/col + 1) to compensate the halo
  int index = (depth+1) * dimx * dimy + (row+1) * dimx + (col+1);
  
  // Compute stencil
  b[index] = coeff[0] * a[index] +
    coeff[1] * a[index-1] +
    coeff[2] * a[index+1] +
    coeff[3] * a[index-dimx] +
    coeff[4] * a[index+dimx] +
    coeff[5] * a[index+(dimx*dimy)] +
    coeff[6] * a[index-(dimx*dimy)];
}

/* 
   Optimization o0: baseline code (no optimization), without using constant coeff
*/
__global__ void calc_stencil_o0_coeff(float *a, float *b, int dimx, int dimy, float c0, float c1, float c2, float c3, float c4, float c5, float c6) {

  int tx = threadIdx.x;
  int ty = threadIdx.y;
  int tz = threadIdx.z;
	
  int row = blockIdx.y * blockDim.y + ty;
  int col = blockIdx.x * blockDim.x + tx;
  int depth = blockIdx.z * blockDim.z + tz;
	
  // (depth/row/col + 1) to compensate the halo
  int index = (depth+1) * dimx * dimy + (row+1) * dimx + (col+1);
  
  // Compute stencil
  b[index] = c0 * a[index] +
    c1 * a[index-1] +
    c2 * a[index+1] +
    c3 * a[index-dimx] +
    c4 * a[index+dimx] +
    c5 * a[index+(dimx*dimy)] +
    c6 * a[index-(dimx*dimy)];
}

/* 
   Optimization o1: shared memory
*/
__global__ void calc_stencil_o1(float *a, float *b, int dimx, int dimy, clock_t *runtime) {

  // Shared Memory Declaration
  __shared__ float ds_a[BLOCK_DIMY+2*RADIUS][BLOCK_DIMX+2*RADIUS];

  int tx = threadIdx.x + RADIUS;
  int ty = threadIdx.y + RADIUS;
  int tz = threadIdx.z + RADIUS;
	
  int row = blockIdx.y * blockDim.y + ty;
  int col = blockIdx.x * blockDim.x + tx;
  int depth = blockIdx.z * blockDim.z + tz;
  
  int index = (depth) * dimx * dimy + (row) * dimx + (col);

  int stride = dimx * dimy; // Distance between 2D slices

  // Measure clock() init of every thread
  // runtime[(depth-RADIUS) * (dimx-2*RADIUS) * (dimy-2*RADIUS) + (row-RADIUS) * (dimx-2*RADIUS) + (col-RADIUS)] = clock64();

  // read_clk_cycles(runtime[0],RADIUS);

  // Load above/below halo data to shared memory
  if (threadIdx.y < RADIUS) {
    ds_a[threadIdx.y][tx] = a[index-(RADIUS*dimx)];
    ds_a[threadIdx.y + BLOCK_DIMY + RADIUS][tx] = a[index+(BLOCK_DIMY*dimx)];
  }

  // Load left/right halo data to shared memory
  if (threadIdx.x < RADIUS) {
    ds_a[ty][threadIdx.x] = a[index-RADIUS];
    ds_a[ty][threadIdx.x + BLOCK_DIMX + RADIUS] = a[index+BLOCK_DIMX];
  }

  // Load current position to shared memory
  ds_a[ty][tx] = a[index];

  __syncthreads();

  // read_clk_cycles(runtime[1],RADIUS);

  // Compute stencil
  b[index] = coeff[0] * ds_a[ty][tx] +
    coeff[1] * ds_a[ty][tx-1] +
    coeff[2] * ds_a[ty][tx+1] +
    coeff[3] * ds_a[ty-1][tx] +
    coeff[4] * ds_a[ty+1][tx] +
    coeff[5] * a[index-stride] +
    coeff[6] * a[index+stride];

  // read_clk_cycles(runtime[2],RADIUS);
}

/* 
   Optimization o2: for iteration on Z axis
*/
__global__ void calc_stencil_o2(float *a, float *b, int dimx, int dimy, int dimz) {

  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
	
  // (depth/row/col + RADIUS) to compensate the halo
  int in_index = (row+RADIUS) * dimx + (col+RADIUS); // Index for reading Z values (+RADIUS to compensate the halo zones)
  int out_index = 0; // Index for writing output
  
  int stride = dimx * dimy; // Distance between 2D slices
  
  register float infront; // Variable to store the value in front (in the Z axis) of the current slice
  register float behind; // Variable to store the value behind (in the Z axis) the current slice
  register float current; // Input value in the current slice

  // Load initial values (behind will be loaded inside the next 'for')
  current = a[in_index];
  out_index = in_index;
  in_index += stride;
  
  infront = a[in_index];
  in_index += stride;

  // Iterate over the Z axis
  for (int i = RADIUS; i < dimz - RADIUS; i++) {

    // Load the new values in Z axis
    behind = current;
    current = infront;
    infront = a[in_index];

    in_index += stride;
    out_index += stride;

    // Compute stencil
    b[out_index] = coeff[0] * current +
      coeff[1] * a[out_index-1] +
      coeff[2] * a[out_index+1] +
      coeff[3] * a[out_index-dimx] +
      coeff[4] * a[out_index+dimx] +
      coeff[5] * behind +
      coeff[6] * infront;
  }

}

/* 
   Optimization o3: for iteration on Z axis without using registers
*/
__global__ void calc_stencil_o3(float *a, float *b, int dimx, int dimy, int dimz) {

  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
	
  // (depth/row/col + RADIUS) to compensate the halo
  int out_index = (row+RADIUS) * dimx + (col+RADIUS); // Index for writing output
  
  int stride = dimx * dimy; // Distance between 2D slices

  // Iterate over the Z axis
  for (int i = RADIUS; i < dimz - RADIUS; i++) {

    out_index += stride;

    // Compute stencil
    b[out_index] = coeff[0] * a[out_index] +
      coeff[1] * a[out_index-1] +
      coeff[2] * a[out_index+1] +
      coeff[3] * a[out_index-dimx] +
      coeff[4] * a[out_index+dimx] +
      coeff[5] * a[out_index-stride] +
      coeff[6] * a[out_index+stride];
  }

}

/* 
   Optimization o2_o5: for iteration on Z axis + pragma unroll
*/
__global__ void calc_stencil_o2_o5(float *a, float *b, int dimx, int dimy, int dimz) {

  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
	
  // (depth/row/col + RADIUS) to compensate the halo
  int in_index = (row+RADIUS) * dimx + (col+RADIUS); // Index for reading Z values (+RADIUS to compensate the halo zones)
  int out_index = 0; // Index for writing output
  
  int stride = dimx * dimy; // Distance between 2D slices
  
  register float infront; // Variable to store the value in front (in the Z axis) of the current slice
  register float behind; // Variable to store the value behind (in the Z axis) the current slice
  register float current; // Input value in the current slice

  // Load initial values (behind will be loaded inside the next 'for')
  current = a[in_index];
  out_index = in_index;
  in_index += stride;
  
  infront = a[in_index];
  in_index += stride;

  // Iterate over the Z axis
  #pragma unroll
  for (int i = RADIUS; i < dimz - RADIUS; i++) {

    // Load the new values in Z axis
    behind = current;
    current = infront;
    infront = a[in_index];

    in_index += stride;
    out_index += stride;

    // Compute stencil
    b[out_index] = coeff[0] * current +
      coeff[1] * a[out_index-1] +
      coeff[2] * a[out_index+1] +
      coeff[3] * a[out_index-dimx] +
      coeff[4] * a[out_index+dimx] +
      coeff[5] * behind +
      coeff[6] * infront;
  }

}

/* 
   Optimization o1_o2: for iteration on Z axis + use of shared memory
*/
__global__ void calc_stencil_o1_o2(float *a, float *b, int dimx, int dimy, int dimz, clock_t *runtime) {

  // Shared memory declaration
  __shared__ float ds_a[BLOCK_DIMY+2*RADIUS][BLOCK_DIMX+2*RADIUS];

  int tx = threadIdx.x + RADIUS;
  int ty = threadIdx.y + RADIUS;

  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
	
  // (depth/row/col + RADIUS) to compensate the halo
  int in_index = (row+RADIUS) * dimx + (col+RADIUS); // Index for reading Z values (+1 to compensate the halo zones)
  int out_index = 0; // Index for writing output
  
  int stride = dimx * dimy; // Distance between 2D slices
  
  register float infront; // Variable to store the value in front (in the Z axis) of the current slice
  register float behind; // Variable to store the value behind (in the Z axis) the current slice
  register float current; // Input value in the current slice

  // register clock_t time_aux1 = 0, time_aux2 = 0, time_aux3 = 0, time_aux4 = 0, time_aux5 = 0;

  // Load initial values (behind will be loaded inside the next 'for')
  current = a[in_index];
  out_index = in_index;
  in_index += stride;
  
  infront = a[in_index];
  in_index += stride;

  // Iterate over the Z axis
  for (int i = RADIUS; i < dimz - RADIUS; i++) {

    // Load the new values in Z axis
    behind = current;
    current = infront;
    infront = a[in_index];

    in_index += stride;
    out_index += stride;

    // if ( (row == RADIUS) && (col == RADIUS) ) { 
    //   time_aux1 = clock64();
    // }

    // Load above/below halo data to shared memory
    if (threadIdx.y < RADIUS) {
      ds_a[threadIdx.y][tx] = a[out_index - (RADIUS * dimx)];
      ds_a[threadIdx.y + BLOCK_DIMY + RADIUS][tx] = a[out_index + (dimx * BLOCK_DIMY)];
    }

    // Load left/right halo data to shared memory
    if (threadIdx.x < RADIUS) {
      ds_a[ty][threadIdx.x] = a[out_index - RADIUS];
      ds_a[ty][threadIdx.x + BLOCK_DIMX + RADIUS] = a[out_index + BLOCK_DIMX];
    }

    // Load current position to shared memory
    ds_a[ty][tx] = current;

    __syncthreads();

    // if ( (row == RADIUS) && (col == RADIUS) ) {
    //   time_aux2 = clock64();
    //   time_aux4 += time_aux2 - time_aux1;
    // }

    // Compute stencil (7 single precision mul + 6 single precision add)
    b[out_index] = coeff[0] * current +
      coeff[1] * ds_a[ty][tx-1] +
      coeff[2] * ds_a[ty][tx+1] +
      coeff[3] * ds_a[ty-1][tx] +
      coeff[4] * ds_a[ty+1][tx] +
      coeff[5] * behind +
      coeff[6] * infront;

    __syncthreads();
  
    // if ( (row == RADIUS) && (col == RADIUS) ) {
    //   time_aux3 = clock64();
    //   time_aux5 += time_aux3 - time_aux2;
    // }
  }
  // if ( (row == RADIUS) && (col == RADIUS) ) {
  //   runtime[0] = time_aux4;
  //   runtime[1] = time_aux5;
  // }
}

/* 
   Optimization o1_o3: for iteration on Z axis without registers + use of shared memory
*/
__global__ void calc_stencil_o1_o3(float *a, float *b, int dimx, int dimy, int dimz, clock_t *runtime) {

  // Shared memory declaration
  __shared__ float ds_a[BLOCK_DIMY+2*RADIUS][BLOCK_DIMX+2*RADIUS];

  int tx = threadIdx.x + RADIUS;
  int ty = threadIdx.y + RADIUS;

  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
	
  // (depth/row/col + RADIUS) to compensate the halo
  int out_index = (row+RADIUS) * dimx + (col+RADIUS); // Index for writing output
  
  int stride = dimx * dimy; // Distance between 2D slices
  
  // Iterate over the Z axis
  for (int i = RADIUS; i < dimz - RADIUS; i++) {

    out_index += stride;

    // Load above/below halo data to shared memory
    if (threadIdx.y < RADIUS) {
      ds_a[threadIdx.y][tx] = a[out_index - (RADIUS * dimx)];
      ds_a[threadIdx.y + BLOCK_DIMY + RADIUS][tx] = a[out_index + (dimx * BLOCK_DIMY)];
    }

    // Load left/right halo data to shared memory
    if (threadIdx.x < RADIUS) {
      ds_a[ty][threadIdx.x] = a[out_index - RADIUS];
      ds_a[ty][threadIdx.x + BLOCK_DIMX + RADIUS] = a[out_index + BLOCK_DIMX];
    }

    // Load current position to shared memory
    ds_a[ty][tx] = a[out_index];

    __syncthreads();

    // Compute stencil (7 single precision mul + 6 single precision add)
    b[out_index] = coeff[0] * ds_a[ty][tx] +
      coeff[1] * ds_a[ty][tx-1] +
      coeff[2] * ds_a[ty][tx+1] +
      coeff[3] * ds_a[ty-1][tx] +
      coeff[4] * ds_a[ty+1][tx] +
      coeff[5] * a[out_index-stride] +
      coeff[6] * a[out_index+stride]; 

    __syncthreads();
  }
}

/* 
   Optimization o1_o2_o4: shared memory + for iteration on Z axis + temporal blocking (will always compute 2 time iterations)
*/
__global__ void calc_stencil_o1_o2_o4(float *a, float *b, int dimx, int dimy, int dimz) {

  // Shared memory declaration
  __shared__ float ds_a[BLOCK_DIMY+2*RADIUS][BLOCK_DIMX+2*RADIUS][2];

  int tx = threadIdx.x + RADIUS;
  int ty = threadIdx.y + RADIUS;

  int row = blockIdx.y * (BLOCK_DIMY-2*RADIUS) + threadIdx.y + RADIUS;
  int col = blockIdx.x * (BLOCK_DIMX-2*RADIUS) + threadIdx.x + RADIUS;
	
  int in_index = row * dimx + col; // Index for reading Z values
  int out_index = 0; // Index for writing output
  int next_index = 0; // Index for plane Z = output + RADIUS
  
  int stride = dimx * dimy; // Distance between 2D slices

  // t0 = t + 0
  register float t0_infront1; // Variable to store the value ahead (in the Z axis) of the current slice
  register float t0_behind1; // Variable to store the value behind (in the Z axis) the current slice
  register float t0_current; // Input value in the current slice

  // t1 = t + 1
  register float t1_infront1; // Variable to store the value ahead (in the Z axis) of the current slice
  register float t1_behind1; // Variable to store the value behind (in the Z axis) the current slice
  register float t1_current; // Value in current slice for t+1

  // Load ghost zones
  in_index += stride;
  t0_behind1 = a[in_index]; // Z = -R = -1
  in_index += stride;
  next_index = in_index; // Z = R-1 = 0
  
  out_index = in_index; // Index for writing output, Z = 0
  
  t0_current = a[in_index]; // Z = 0
  in_index += stride;
  t0_infront1 = a[in_index]; // Z = (2R-1) = 1
  in_index += stride;

  // Load Z = 0 to shared memory
  // Load above/below halo data
  if (threadIdx.y < RADIUS) {
    ds_a[threadIdx.y][tx][1] = a[out_index - (RADIUS * dimx)];
    ds_a[threadIdx.y + BLOCK_DIMY + RADIUS][tx][1] = a[out_index + (dimx * BLOCK_DIMY)];
  }
  
  // Load left/right halo data
  if (threadIdx.x < RADIUS) {
    ds_a[ty][threadIdx.x][1] = a[out_index - RADIUS];
    ds_a[ty][threadIdx.x + BLOCK_DIMX + RADIUS][1] = a[out_index + BLOCK_DIMX];
  }
  ds_a[ty][tx][1] = t0_current;

  __syncthreads();

  // Compute stencil for Z = 0 (t + 1) but exclude ghost zones 
   if ( (row >= 2*RADIUS) && (row < (dimy-2*RADIUS)) && (col >= 2*RADIUS) && (col < (dimx-2*RADIUS)) ) {
    t1_current = coeff[0] * t0_current +
     coeff[1] * ds_a[ty][tx-1][1] +
      coeff[2] * ds_a[ty][tx+1][1] +
      coeff[3] * ds_a[ty-1][tx][1] +
      coeff[4] * ds_a[ty+1][tx][1] +
      coeff[5] * t0_behind1 +
      coeff[6] * t0_infront1;
   } else {
     t1_current = t0_current;
   }
  
  // Copy planes Z = -1 to -R to registers in t+1 (ghost zones, keep values in 0.0)
  t1_behind1 = t0_behind1;
  
  __syncthreads();

  for (int i = 0; i < dimz-(4*RADIUS); i++) {

    // Load Z = (2R+i) to registers
    t0_behind1 = t0_current;
    t0_current = t0_infront1;
    t0_infront1 = a[in_index]; // Z = 2R+i   

    in_index += stride;
    next_index += stride;
    
    // Load Z = R+i to shared memory
    if (threadIdx.y < RADIUS) {
      ds_a[threadIdx.y][tx][1] = a[next_index - (RADIUS * dimx)];
      ds_a[threadIdx.y + BLOCK_DIMY + RADIUS][tx][1] = a[next_index + (dimx * BLOCK_DIMY)];
    }
  
    // Load left/right halo data
    if (threadIdx.x < RADIUS) {
      ds_a[ty][threadIdx.x][1] = a[next_index - RADIUS];
      ds_a[ty][threadIdx.x + BLOCK_DIMX + RADIUS][1] = a[next_index + BLOCK_DIMX];
    }
    ds_a[ty][tx][1] = t0_current;

    __syncthreads();

    // Compute stencil for Z = R+i (t + 1) but exclude ghost zones
    if ( (row >= 2*RADIUS) && (row < (dimy-2*RADIUS)) && (col >= 2*RADIUS) && (col < (dimx-2*RADIUS)) && (i < dimz-5*RADIUS) ) {
      t1_infront1 = coeff[0] * t0_current +
	coeff[1] * ds_a[ty][tx-1][1] +
	coeff[2] * ds_a[ty][tx+1][1] +
	coeff[3] * ds_a[ty-1][tx][1] +
	coeff[4] * ds_a[ty+1][tx][1] +
	coeff[5] * t0_behind1 +
	coeff[6] * t0_infront1;
    } else {
      t1_infront1 = t0_current;
    }

    __syncthreads();

    // Load Z = k (t + 1) to shared memory
    ds_a[ty][tx][0] = t1_current;

    __syncthreads();
    
    // Compute stencil for Z = k (t + 2) but exclude halo zones
    if ( (threadIdx.y >= RADIUS) && (threadIdx.y < (BLOCK_DIMY-RADIUS)) && (threadIdx.x >= RADIUS) && (threadIdx.x < (BLOCK_DIMX-RADIUS)) ) {    
      b[out_index] = coeff[0] * t1_current +
	coeff[1] * ds_a[ty][tx-1][0] +
	coeff[2] * ds_a[ty][tx+1][0] +
	coeff[3] * ds_a[ty-1][tx][0] +
	coeff[4] * ds_a[ty+1][tx][0] +
	coeff[5] * t1_behind1 +
	coeff[6] * t1_infront1;
    }

    out_index += stride;
    t1_behind1 = t1_current;
    t1_current = t1_infront1;
  }

}

/* 
   Optimization o1_o2_o5: for iteration on Z axis + use of shared memory + pragma unroll
*/
__global__ void calc_stencil_o1_o2_o5(float *a, float *b, int dimx, int dimy, int dimz, clock_t *runtime) {

  // Shared memory declaration
  __shared__ float ds_a[BLOCK_DIMY+2*RADIUS][BLOCK_DIMX+2*RADIUS];

  int tx = threadIdx.x + RADIUS;
  int ty = threadIdx.y + RADIUS;

  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
	
  // (depth/row/col + RADIUS) to compensate the halo
  int in_index = (row+RADIUS) * dimx + (col+RADIUS); // Index for reading Z values (+1 to compensate the halo zones)
  int out_index = 0; // Index for writing output
  
  int stride = dimx * dimy; // Distance between 2D slices
  
  register float infront; // Variable to store the value in front (in the Z axis) of the current slice
  register float behind; // Variable to store the value behind (in the Z axis) the current slice
  register float current; // Input value in the current slice

  // register clock_t time_aux1 = 0, time_aux2 = 0, time_aux3 = 0, time_aux4 = 0, time_aux5 = 0;

  // Load initial values (behind will be loaded inside the next 'for')
  current = a[in_index];
  out_index = in_index;
  in_index += stride;
  
  infront = a[in_index];
  in_index += stride;

  // Iterate over the Z axis
  #pragma unroll
  for (int i = RADIUS; i < dimz - RADIUS; i++) {

    // Load the new values in Z axis
    behind = current;
    current = infront;
    infront = a[in_index];

    in_index += stride;
    out_index += stride;

    // if ( (row == RADIUS) && (col == RADIUS) ) { 
    //   time_aux1 = clock64();
    // }

    // Load above/below halo data to shared memory
    if (threadIdx.y < RADIUS) {
      ds_a[threadIdx.y][tx] = a[out_index - (RADIUS * dimx)];
      ds_a[threadIdx.y + BLOCK_DIMY + RADIUS][tx] = a[out_index + (dimx * BLOCK_DIMY)];
    }

    // Load left/right halo data to shared memory
    if (threadIdx.x < RADIUS) {
      ds_a[ty][threadIdx.x] = a[out_index - RADIUS];
      ds_a[ty][threadIdx.x + BLOCK_DIMX + RADIUS] = a[out_index + BLOCK_DIMX];
    }

    // Load current position to shared memory
    ds_a[ty][tx] = current;

    __syncthreads();

    // if ( (row == RADIUS) && (col == RADIUS) ) {
    //   time_aux2 = clock64();
    //   time_aux4 += time_aux2 - time_aux1;
    // }

    // Compute stencil (7 single precision mul + 6 single precision add)
    b[out_index] = coeff[0] * current +
      coeff[1] * ds_a[ty][tx-1] +
      coeff[2] * ds_a[ty][tx+1] +
      coeff[3] * ds_a[ty-1][tx] +
      coeff[4] * ds_a[ty+1][tx] +
      coeff[5] * behind +
      coeff[6] * infront;
  
    // if ( (row == RADIUS) && (col == RADIUS) ) {
    //   time_aux3 = clock64();
    //   time_aux5 += time_aux3 - time_aux2;
    // }
  }
  // if ( (row == RADIUS) && (col == RADIUS) ) {
  //   runtime[0] = time_aux4;
  //   runtime[1] = time_aux5;
  // }
}

/* 
   Optimization o7: use of read only cache (texture memory)
*/
__global__ void calc_stencil_o7(const float* __restrict__ a, float* __restrict__ b, int dimx, int dimy) {

  int tx = threadIdx.x;
  int ty = threadIdx.y;
  int tz = threadIdx.z;
	
  int row = blockIdx.y * blockDim.y + ty;
  int col = blockIdx.x * blockDim.x + tx;
  int depth = blockIdx.z * blockDim.z + tz;
	
  // (depth/row/col + 1) to compensate the halo
  int index = (depth+1) * dimx * dimy + (row+1) * dimx + (col+1);
  
  // Compute stencil
  b[index] = coeff[0] * __ldg(&a[index]) +
    coeff[1] * __ldg(&a[index-1]) +
    coeff[2] * __ldg(&a[index+1]) +
    coeff[3] * __ldg(&a[index-dimx]) +
    coeff[4] * __ldg(&a[index+dimx]) +
    coeff[5] * __ldg(&a[index+(dimx*dimy)]) +
    coeff[6] * __ldg(&a[index-(dimx*dimy)]);
}

/* 
   Optimization o1_o7: use of shared memory + read only cache (texture memory)
*/
__global__ void calc_stencil_o1_o7(const float* __restrict__ a, float* __restrict__ b, int dimx, int dimy, clock_t *runtime) {

  // Shared Memory Declaration
  __shared__ float ds_a[BLOCK_DIMY+2*RADIUS][BLOCK_DIMX+2*RADIUS];

  int tx = threadIdx.x + RADIUS;
  int ty = threadIdx.y + RADIUS;
  int tz = threadIdx.z + RADIUS;
	
  int row = blockIdx.y * blockDim.y + ty;
  int col = blockIdx.x * blockDim.x + tx;
  int depth = blockIdx.z * blockDim.z + tz;
  
  int index = (depth) * dimx * dimy + (row) * dimx + (col);

  int stride = dimx * dimy; // Distance between 2D slices

  // Measure clock() init of every thread
  // runtime[(depth-RADIUS) * (dimx-2*RADIUS) * (dimy-2*RADIUS) + (row-RADIUS) * (dimx-2*RADIUS) + (col-RADIUS)] = clock64();

  // read_clk_cycles(runtime[0],RADIUS);

  // Load above/below halo data to shared memory
  if (threadIdx.y < RADIUS) {
    ds_a[threadIdx.y][tx] = __ldg(&a[index-(RADIUS*dimx)]);
    ds_a[threadIdx.y + BLOCK_DIMY + RADIUS][tx] = __ldg(&a[index+(BLOCK_DIMY*dimx)]);
  }

  // Load left/right halo data to shared memory
  if (threadIdx.x < RADIUS) {
    ds_a[ty][threadIdx.x] = __ldg(&a[index-RADIUS]);
    ds_a[ty][threadIdx.x + BLOCK_DIMX + RADIUS] = __ldg(&a[index+BLOCK_DIMX]);
  }

  // Load current position to shared memory
  ds_a[ty][tx] = __ldg(&a[index]);

  __syncthreads();

  // read_clk_cycles(runtime[1],RADIUS);

  // Compute stencil
  b[index] = coeff[0] * ds_a[ty][tx] +
    coeff[1] * ds_a[ty][tx-1] +
    coeff[2] * ds_a[ty][tx+1] +
    coeff[3] * ds_a[ty-1][tx] +
    coeff[4] * ds_a[ty+1][tx] +
    coeff[5] * __ldg(&a[index-stride]) +
    coeff[6] * __ldg(&a[index+stride]);

  // read_clk_cycles(runtime[2],RADIUS);
}

/* 
   Optimization o2_o7: use of iteration on Z axis + read only cache (texture memory)
*/

__global__ void calc_stencil_o2_o7(const float* __restrict__ a, float* __restrict__ b, int dimx, int dimy, int dimz) {

  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
	
  // (depth/row/col + RADIUS) to compensate the halo
  int in_index = (row+RADIUS) * dimx + (col+RADIUS); // Index for reading Z values (+1 to compensate the halo zones)
  int out_index = 0; // Index for writing output
  
  int stride = dimx * dimy; // Distance between 2D slices
  
  register float infront; // Variable to store the value in front (in the Z axis) of the current slice
  register float behind; // Variable to store the value behind (in the Z axis) the current slice
  register float current; // Input value in the current slice

  // Load initial values (behind will be loaded inside the next 'for')
  current = __ldg(&a[in_index]);
  out_index = in_index;
  in_index += stride;
  
  infront = __ldg(&a[in_index]);
  in_index += stride;

  // Iterate over the Z axis
  for (int i = RADIUS; i < dimz - RADIUS; i++) {

    // Load the new values in Z axis
    behind = current;
    current = infront;
    infront = __ldg(&a[in_index]);

    in_index += stride;
    out_index += stride;

    // Compute stencil
    b[out_index] = coeff[0] * current +
      coeff[1] * __ldg(&a[out_index-1]) +
      coeff[2] * __ldg(&a[out_index+1]) +
      coeff[3] * __ldg(&a[out_index-dimx]) +
      coeff[4] * __ldg(&a[out_index+dimx]) +
      coeff[5] * behind +
      coeff[6] * infront;
  }

}

/* 
   Optimization o3_o7: use of iteration on Z axis without registers + read only cache (texture memory)
*/

__global__ void calc_stencil_o3_o7(const float* __restrict__ a, float* __restrict__ b, int dimx, int dimy, int dimz) {

  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
	
  // (depth/row/col + 1) to compensate the halo
  int out_index = (row+RADIUS) * dimx + (col+RADIUS); // Index for writing output
  
  int stride = dimx * dimy; // Distance between 2D slices
  
  // Iterate over the Z axis
  for (int i = RADIUS; i < dimz - RADIUS; i++) {

    out_index += stride;

    // Compute stencil
    b[out_index] = coeff[0] * __ldg(&a[out_index]) +
      coeff[1] * __ldg(&a[out_index-1]) +
      coeff[2] * __ldg(&a[out_index+1]) +
      coeff[3] * __ldg(&a[out_index-dimx]) +
      coeff[4] * __ldg(&a[out_index+dimx]) +
      coeff[5] * __ldg(&a[out_index-stride]) +
      coeff[6] * __ldg(&a[out_index+stride]);
  }

}

/* 
   Optimization o1_o2_o4_o7: shared memory + for iteration on Z axis + temporal blocking (will always compute 2 time iterations)
*/
__global__ void calc_stencil_o1_o2_o4_o7(const float* __restrict__ a, float* __restrict__ b, int dimx, int dimy, int dimz) {

  // Shared memory declaration
  __shared__ float ds_a[BLOCK_DIMY][BLOCK_DIMX];

  int row = blockIdx.y * (BLOCK_DIMY-2*RADIUS) + threadIdx.y + RADIUS;
  int col = blockIdx.x * (BLOCK_DIMX-2*RADIUS) + threadIdx.x + RADIUS;
	
  int in_index = row * dimx + col; // Index for reading Z values
  int out_index = 0; // Index for writing output
  int next_index = 0; // Index for plane Z = output + RADIUS
  
  int stride = dimx * dimy; // Distance between 2D slices

  // t0 = t + 0
  register float t0_infront1; // Variable to store the value ahead (in the Z axis) of the current slice
  register float t0_behind1; // Variable to store the value behind (in the Z axis) the current slice
  register float t0_current; // Input value in the current slice

  // t1 = t + 1
  register float t1_infront1; // Variable to store the value ahead (in the Z axis) of the current slice
  register float t1_behind1; // Variable to store the value behind (in the Z axis) the current slice
  register float t1_current; // Value in current slice for t+1

  // Load ghost zones
  in_index += stride;
  t0_behind1 = __ldg(&a[in_index]); // Z = -R
  in_index += stride;
  next_index = in_index + ((RADIUS-1)*stride); // Z = R-1
  
  out_index = in_index; // Index for writing output, Z = 0
  
  // Load current to (2RADIUS-1) planes
  t0_current = __ldg(&a[in_index]); // Z = 0
  in_index += stride;
  t0_infront1 = __ldg(&a[in_index]); // Z = (2R-1) = 1
  in_index += stride;

  // Compute stencil for Z = 0 (t + 1) but exclude ghost zones 
   if ( (row >= 2*RADIUS) && (row < (dimy-2*RADIUS)) && (col >= 2*RADIUS) && (col < (dimx-2*RADIUS)) ) {
    t1_current = coeff[0] * t0_current +
      coeff[1] * __ldg(&a[out_index-1]) +
      coeff[2] * __ldg(&a[out_index+1]) +
      coeff[3] * __ldg(&a[out_index-dimx]) +
      coeff[4] * __ldg(&a[out_index+dimx]) +
      coeff[5] * t0_behind1 +
      coeff[6] * t0_infront1;
   } else {
     t1_current = t0_current;
   }
  
  // Copy planes Z = -1 to -R to registers in t+1 (ghost zones, keep values in 0.0)
  t1_behind1 = t0_behind1;
  
  for (int i = 0; i < dimz-(4*RADIUS); i++) {
    // Load Z = (2R+i) to registers
    t0_behind1 = t0_current;
    t0_current = t0_infront1;
    t0_infront1 = __ldg(&a[in_index]); // Z = 2R+i   

    in_index += stride;
    next_index += stride;
    
    // Compute stencil for Z = R+i (t + 1) but exclude ghost zones
    if ( (row >= 2*RADIUS) && (row < (dimy-2*RADIUS)) && (col >= 2*RADIUS) && (col < (dimx-2*RADIUS)) && (i < dimz-5*RADIUS) ) {
      t1_infront1 = coeff[0] * t0_current +
	coeff[1] * __ldg(&a[next_index-1]) +
	coeff[2] * __ldg(&a[next_index+1]) +
	coeff[3] * __ldg(&a[next_index-dimx]) +
	coeff[4] * __ldg(&a[next_index+dimx]) +
	coeff[5] * t0_behind1 +
	coeff[6] * t0_infront1;
    } else {
      t1_infront1 = t0_current;
    }

    __syncthreads();

    // Load Z = k (t + 1) to shared memory
    ds_a[threadIdx.y][threadIdx.x] = t1_current;
    
    __syncthreads();

    // Compute stencil for Z = k (t + 2) but exclude halo zones
    if ( (threadIdx.y >= RADIUS) && (threadIdx.y < (BLOCK_DIMY-RADIUS)) && (threadIdx.x >= RADIUS) && (threadIdx.x < (BLOCK_DIMX-RADIUS)) ) {    
      b[out_index] = coeff[0] * t1_current +
	coeff[1] * ds_a[threadIdx.y][threadIdx.x-1] +
	coeff[2] * ds_a[threadIdx.y][threadIdx.x+1] +
	coeff[3] * ds_a[threadIdx.y-1][threadIdx.x] +
	coeff[4] * ds_a[threadIdx.y+1][threadIdx.x] +
	coeff[5] * t1_behind1 +
	coeff[6] * t1_infront1;
    }

    out_index += stride;
    t1_behind1 = t1_current;
    t1_current = t1_infront1;
  }
  
}

void initGold(float *a, int dimx, int dimy, int dimz) {

  for (int i = 0; i < dimz; i++) {
    for (int j = 0; j < dimy; j++) {
      for (int k = 0; k < dimx; k++) {
	if (i<RADIUS || j<RADIUS || i>=dimz-RADIUS || j>=dimy-RADIUS || k<RADIUS || k>=dimx-RADIUS) {
	  a[i*dimx*dimy + j*dimx + k] = 0.0;
        } else {
	  a[i*dimx*dimy + j*dimx + k] = 1.0;
	}
      }
    }
  }

}

void initGoldTemporal(float *a, int dimx, int dimy, int dimz) {

  for (int i = 0; i < dimz; i++) {
    for (int j = 0; j < dimy; j++) {
      for (int k = 0; k < dimx; k++) {
	if (i<2*RADIUS || j<2*RADIUS || i>=dimz-2*RADIUS || j>=dimy-2*RADIUS || k<2*RADIUS || k>=dimx-2*RADIUS) {
	  a[i*dimx*dimy + j*dimx + k] = 0.0;
        } else {
	  a[i*dimx*dimy + j*dimx + k] = 1.0;
	}
      }
    }
  }

}

void hostStencil(float *a, int t_end, int dimx, int dimy, int dimz, float *hcoeff) {

  float *b;

  b = (float *)malloc(dimx * dimy * dimz * sizeof(float));
  initGold(b, dimx, dimy, dimz);

  for (int t = 0; t < t_end; t++) {
    for (int i = 1; i < dimz-1; i++) {
      for (int j = 1; j < dimy-1; j++) {
	for (int k = 1; k < dimx-1; k++) {
	  int index = i*dimx*dimy + j*dimx + k;
	  if (t%2) {
	    a[index] = hcoeff[0] * b[index] +
	      hcoeff[1] * b[index-1] +
	      hcoeff[2] * b[index+1] +
	      hcoeff[3] * b[index-dimx] +
	      hcoeff[4] * b[index+dimx] +
	      hcoeff[5] * b[index-(dimx*dimy)] +
	      hcoeff[6] * b[index+(dimx*dimy)];
	  } else {
	    b[index] = hcoeff[0] * a[index] +
	      hcoeff[1] * a[index-1] +
	      hcoeff[2] * a[index+1] +
	      hcoeff[3] * a[index-dimx] +
	      hcoeff[4] * a[index+dimx] +
	      hcoeff[5] * a[index-(dimx*dimy)] +
	      hcoeff[6] * a[index+(dimx*dimy)];
	  }
	}
      }
    }
  }  

  if (t_end%2) {
    for (int i = 1; i < dimz-1; i++) {
      for (int j = 1; j < dimy-1; j++) {
	for (int k = 1; k < dimx-1; k++) {
	  a[i*dimx*dimy + j*dimx + k] = b[i*dimx*dimy + j*dimx + k];
	}
      }
    }    
  } 
  free(b);

}

void hostStencilTemporal(float *a, int t_end, int dimx, int dimy, int dimz, float *hcoeff) {

  float *b;

  b = (float *)malloc(dimx * dimy * dimz * sizeof(float));
  initGoldTemporal(b, dimx, dimy, dimz);

  for (int t = 0; t < t_end; t++) {
    for (int i = 2*RADIUS; i < dimz-2*RADIUS; i++) {
      for (int j = 2*RADIUS; j < dimy-2*RADIUS; j++) {
	for (int k = 2*RADIUS; k < dimx-2*RADIUS; k++) {
	  int index = i*dimx*dimy + j*dimx + k;
	  if (t%2) {
	    a[index] = hcoeff[0] * b[index] +
	      hcoeff[1] * b[index-1] +
	      hcoeff[2] * b[index+1] +
	      hcoeff[3] * b[index-dimx] +
	      hcoeff[4] * b[index+dimx] +
	      hcoeff[5] * b[index-(dimx*dimy)] +
	      hcoeff[6] * b[index+(dimx*dimy)];
	  } else {
	    b[index] = hcoeff[0] * a[index] +
	      hcoeff[1] * a[index-1] +
	      hcoeff[2] * a[index+1] +
	      hcoeff[3] * a[index-dimx] +
	      hcoeff[4] * a[index+dimx] +
	      hcoeff[5] * a[index-(dimx*dimy)] +
	      hcoeff[6] * a[index+(dimx*dimy)];
	  }
	}
      }
    }
  }  

  if (t_end%2) {
    for (int i = 2*RADIUS; i < dimz-2*RADIUS; i++) {
      for (int j = 2*RADIUS; j < dimy-2*RADIUS; j++) {
	for (int k = 2*RADIUS; k < dimx-2*RADIUS; k++) {
	  a[i*dimx*dimy + j*dimx + k] = b[i*dimx*dimy + j*dimx + k];
	}
      }
    }    
  } 
  free(b);

}


void printMatrix(float *a, int dimx, int dimy, int dimz) {
 
  for (int k=0; k < dimz; k++) {    
    for (int i=0; i < dimy; i++) {
      for (int j=0; j < dimx; j++) {
	printf("%f, ",a[k*dimx*dimy + i*dimx + j]);
      }
      printf("\n");
    }
    printf("\n");
  }
}

bool checkResult(float *a, float *ref, int dimx, int dimy, int dimz) {

  for (int i = 0; i < dimz; i++) {
    for (int j = 0; j < dimy; j++) {
      for (int k = 0; k < dimx; k++) {
	if (a[i*dimx*dimy + j*dimx + k] != ref[i*dimx*dimy + j*dimx + k]) {
	  printf("Expected: %f, received: %f at position [%d,%d,%d]\n",ref[i*dimx*dimy+j*dimx+k],a[i*dimx*dimy+j*dimx+k],i,j,k);
	  return 0;
	}
      }
    }
  }    

  return 1;

}

int main(int argc, char* argv[]) {

  float *h_a, *h_gold_a;
  float *d_a, *d_b;
  float hcoeff[7] = {1.0,1.0,1.0,1.0,1.0,1.0,1.0}; //cc, cw, ce, cn, cs, ct, cb

  cudaEvent_t t0, t1, t2, t3, t4, t5;
  float init, host_comp, host2gpu, gpu2host, gpu_comp, tot;
  int dimx, dimy, dimz, t_end;
  long points, flop;
  float gFlops;
  int opt; // Variable to select the optimization

#ifdef MEASURE_KERNEL_RUNTIME
  clock_t *h_runtime; // Variables to benchmark elapsed time (in clock cycles) inside the kernel
#endif
  clock_t *d_runtime;

  if (argc != 6) {
    printf(" use: <exec> <OPT> <DIMX> <DIMY> <DIMZ> <T_END>\n");
    exit(-1);
  }
  opt = atoi(argv[1]);
  dimx = atoi(argv[2]);
  dimy = atoi(argv[3]);
  dimz = atoi(argv[4]);
  t_end = atoi(argv[5]);

  cudaDeviceProp prop;
  cudaGetDeviceProperties(&prop, 0);

  cudaEventCreate(&t0);
  cudaEventCreate(&t1);
  cudaEventCreate(&t2);
  cudaEventCreate(&t3);
  cudaEventCreate(&t4);
  cudaEventCreate(&t5);

  int gold_size;

  // If temporal blocking is requested, allocate more device memory
  if ( (opt == 124) || (opt == 1247) ) {
    gold_size = (dimx+4*RADIUS) * (dimy+4*RADIUS) * (dimz+4*RADIUS) * sizeof(float);
    // Check if the number of iterations is even
    if ( (t_end%2) != 0) {
      printf("Number of time iterations is odd, adding one iteration!\n");
      t_end++;
    }
  } else {
    gold_size = (dimx+2*RADIUS) * (dimy+2*RADIUS) * (dimz+2*RADIUS) * sizeof(float);
  }
  points = (long)dimx * (long)dimy * (long)dimz * (long)t_end;
  flop = (long)(6 + 7) * points; // 6 adds, 7 multiplies

  cudaEventRecord(t0);

  /* allocate device variables */
  wbCheck(cudaMalloc((void**) &d_a, gold_size));
  wbCheck(cudaMalloc((void**) &d_b, gold_size));
  wbCheck(cudaMalloc((void**) &d_runtime, 3*sizeof(clock_t)));
  // wbCheck(cudaMalloc((void**) &d_runtime, 3*BLOCK_DIMX*BLOCK_DIMY*sizeof(clock_t)));

  /* allocate host variables */
  h_a = (float *)malloc(gold_size);
  h_gold_a = (float *)malloc(gold_size);

#ifdef MEASURE_KERNEL_RUNTIME
  h_runtime = (clock_t *)malloc(3*sizeof(clock_t));
  // h_runtime = (clock_t *)malloc(3*BLOCK_DIMX*BLOCK_DIMY*sizeof(clock_t));
#endif

  if ( (opt == 124) || (opt == 1247) ) {
    initGoldTemporal(h_a, dimx+4*RADIUS, dimy+4*RADIUS, dimz+4*RADIUS);
    initGoldTemporal(h_gold_a, dimx+4*RADIUS, dimy+4*RADIUS, dimz+4*RADIUS);
  } else {
    initGold(h_a, dimx+2*RADIUS, dimy+2*RADIUS, dimz+2*RADIUS);
    initGold(h_gold_a, dimx+2*RADIUS, dimy+2*RADIUS, dimz+2*RADIUS);
  }

  cudaEventRecord(t1);

  if ( (opt == 124) || (opt == 1247) ) {
    hostStencilTemporal(h_gold_a, t_end, dimx+4*RADIUS, dimy+4*RADIUS, dimz+4*RADIUS, hcoeff);
  } else {
    hostStencil(h_gold_a, t_end, dimx+2*RADIUS, dimy+2*RADIUS, dimz+2*RADIUS, hcoeff);
  }
  
#ifdef PRINT_GOLD
  if ( (opt == 124) || (opt == 1247) ) {
    printMatrix(h_gold_a,dimx+4*RADIUS, dimy+4*RADIUS, dimz+4*RADIUS);    
  } else {  
    printMatrix(h_gold_a,dimx+2*RADIUS, dimy+2*RADIUS, dimz+2*RADIUS);
  }
#endif

  cudaEventRecord(t2);

  wbCheck(cudaMemcpyToSymbol(coeff, hcoeff, sizeof(hcoeff)));
  wbCheck(cudaMemcpy(d_a, h_a, gold_size, cudaMemcpyHostToDevice)); // Initialize device values
  wbCheck(cudaMemcpy(d_b, d_a, gold_size, cudaMemcpyDeviceToDevice)); // Copy contents from d_a to d_b
 
  cudaEventRecord(t3);

  dim3 dimBlock;
  dim3 dimGrid;

  switch (opt) {
  case 0:
    printf("Optimization level: o0\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = BLOCK_DIMZ;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = (int)ceil(dimz/BLOCK_DIMZ);

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o0 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2);
      } else {
	calc_stencil_o0 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 1:
    printf("Optimization level: o1\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = BLOCK_DIMZ;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = (int)ceil(dimz/BLOCK_DIMZ);

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o1 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2, d_runtime);
      } else {
	calc_stencil_o1 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2, d_runtime);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 2:
    printf("Optimization level: o2\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = 1;

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o2 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2, dimz+2);
      } else {
	calc_stencil_o2 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2, dimz+2);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 3:
    printf("Optimization level: o3\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = 1;

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o3 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2, dimz+2);
      } else {
	calc_stencil_o3 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2, dimz+2);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 25:
    printf("Optimization level: o2_o5\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = 1;

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o2_o5 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2, dimz+2);
      } else {
	calc_stencil_o2_o5 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2, dimz+2);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 12:
    printf("Optimization level: o1_o2\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = 1;

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o1_o2 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2, dimz+2, d_runtime);
      } else {
	calc_stencil_o1_o2 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2, dimz+2, d_runtime);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 13:
    printf("Optimization level: o1_o3\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = 1;

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o1_o3 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2, dimz+2, d_runtime);
      } else {
	calc_stencil_o1_o3 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2, dimz+2, d_runtime);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 124:
    printf("Optimization level: o1_o2_o4\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(dimx/(BLOCK_DIMX-2*RADIUS));
    dimGrid.y = (int)ceil(dimy/(BLOCK_DIMY-2*RADIUS));
    dimGrid.z = 1;

    for (int i = 0; i < t_end/2; i++) {
      if (i%2) {
	calc_stencil_o1_o2_o4 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+4*RADIUS, dimy+4*RADIUS, dimz+4*RADIUS);
      } else {
	calc_stencil_o1_o2_o4 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+4*RADIUS, dimy+4*RADIUS, dimz+4*RADIUS);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 125:
    printf("Optimization level: o1_o2_o5\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = 1;

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o1_o2_o5 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2, dimz+2, d_runtime);
      } else {
	calc_stencil_o1_o2_o5 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2, dimz+2, d_runtime);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 7:
    printf("Optimization level: o7\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = BLOCK_DIMZ;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = (int)ceil(dimz/BLOCK_DIMZ);

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o7 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2);
      } else {
	calc_stencil_o7 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 17:
    printf("Optimization level: o1_o7\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = BLOCK_DIMZ;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = (int)ceil(dimz/BLOCK_DIMZ);

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o1_o7 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2, d_runtime);
      } else {
	calc_stencil_o1_o7 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2, d_runtime);
      }
      wbCheck(cudaGetLastError());
    }
    break;

  case 27:
    printf("Optimization level: o2_o7\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = 1;

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o2_o7 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2, dimz+2);
      } else {
	calc_stencil_o2_o7 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2, dimz+2);
      }
      wbCheck(cudaGetLastError());
    }
    break;    

  case 37:
    printf("Optimization level: o3_o7\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(dimx/BLOCK_DIMX);
    dimGrid.y = (int)ceil(dimy/BLOCK_DIMY);
    dimGrid.z = 1;

    for (int i = 0; i < t_end; i++) {
      if (i%2) {
	calc_stencil_o3_o7 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+2, dimy+2, dimz+2);
      } else {
	calc_stencil_o3_o7 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+2, dimy+2, dimz+2);
      }
      wbCheck(cudaGetLastError());
    }
    break;    

  case 1247:
    printf("Optimization level: o1_o2_o4_o7\n");
    dimBlock.x = BLOCK_DIMX;
    dimBlock.y = BLOCK_DIMY;
    dimBlock.z = 1;
    dimGrid.x = (int)ceil(dimx/(BLOCK_DIMX-2*RADIUS));
    dimGrid.y = (int)ceil(dimy/(BLOCK_DIMY-2*RADIUS));
    dimGrid.z = 1;

    for (int i = 0; i < t_end/2; i++) {
      if (i%2) {
	calc_stencil_o1_o2_o4_o7 <<< dimGrid,dimBlock >>> (d_b, d_a, dimx+4*RADIUS, dimy+4*RADIUS, dimz+4*RADIUS);
      } else {
	calc_stencil_o1_o2_o4_o7 <<< dimGrid,dimBlock >>> (d_a, d_b, dimx+4*RADIUS, dimy+4*RADIUS, dimz+4*RADIUS);
      }
      wbCheck(cudaGetLastError());
    }
    break;
    
  default:
    printf("Invalid optimization selected\n");
    break;
  }

  cudaEventRecord(t4);
  cudaDeviceSynchronize();

  if ( (opt == 124) || (opt == 1247) ) {
    if ((t_end/2)%2) {
      wbCheck(cudaMemcpy(h_a, d_b, gold_size, cudaMemcpyDeviceToHost));
    } else {
      wbCheck(cudaMemcpy(h_a, d_a, gold_size, cudaMemcpyDeviceToHost));
    }
  } else {
    if (t_end%2) {
      wbCheck(cudaMemcpy(h_a, d_b, gold_size, cudaMemcpyDeviceToHost));
    } else {
      wbCheck(cudaMemcpy(h_a, d_a, gold_size, cudaMemcpyDeviceToHost));
    }
  }
  
  cudaEventRecord(t5);

#ifdef MEASURE_KERNEL_RUNTIME
  wbCheck(cudaMemcpy(h_runtime, d_runtime, 3*sizeof(clock_t), cudaMemcpyDeviceToHost));
  printf("First run time: %f ms\n",((float)(h_runtime[1]-h_runtime[0])/(float)prop.clockRate));
  printf("Second run time: %f ms\n",((float)(h_runtime[2]-h_runtime[1])/(float)prop.clockRate));
#endif

  // wbCheck(cudaMemcpy(h_runtime, d_runtime, 3*sizeof(clock_t), cudaMemcpyDeviceToHost));
  // printf("Shared memory run time: %f ms\n",((float)(h_runtime[0])/(float)prop.clockRate));
  // printf("Computation run time: %f ms\n",((float)(h_runtime[1])/(float)prop.clockRate));

  // Measure init clock() for every thread
  // wbCheck(cudaMemcpy(h_runtime, d_runtime, 3*BLOCK_DIMX*BLOCK_DIMY*sizeof(clock_t), cudaMemcpyDeviceToHost));
  // for (int i = 0; i < 3*BLOCK_DIMX*BLOCK_DIMY; i++) printf("runtime[%d] = \t \t %d\n",i,h_runtime[i]);

  cudaFree(d_a);
  cudaFree(d_b);
 
#ifdef PRINT_RESULT
  if ( (opt == 124) || (opt == 1247) ) {
    printMatrix(h_a,dimx+4*RADIUS,dimy+4*RADIUS,dimz+4*RADIUS);
  } else {
    printMatrix(h_a,dimx+2*RADIUS,dimy+2*RADIUS,dimz+2*RADIUS);
  }
#endif

  if ( (opt == 124) || (opt == 1247) ) {
    if (checkResult(h_a,h_gold_a,dimx+4*RADIUS,dimy+4*RADIUS,dimz+4*RADIUS)) {
      printf("Correct results!\n");
    } else {
      printf("Wrong results!!!!!!\n");
    }
  } else {
    if (checkResult(h_a,h_gold_a,dimx+2*RADIUS,dimy+2*RADIUS,dimz+2*RADIUS)) {
      printf("Correct results!\n");
    } else {
      printf("Wrong results!!!!!!\n");
    }
  }
  
  cudaEventSynchronize(t5);

  cudaEventElapsedTime(&init, t0, t1);
  cudaEventElapsedTime(&host_comp, t1, t2);
  cudaEventElapsedTime(&host2gpu, t2, t3);
  cudaEventElapsedTime(&gpu_comp, t3, t4);
  cudaEventElapsedTime(&gpu2host, t4, t5);
  cudaEventElapsedTime(&tot, t0, t5);

  gFlops = (1.0e-6)*flop/gpu_comp;
  
  printf("GPU Clock: %d MHz\n",prop.clockRate/1000);
  printf("DIM = %dx%dx%d; T_END = %d; BLOCK_WIDTH = %dx%dx%d\n", dimx,dimy,dimz,t_end,BLOCK_DIMX,BLOCK_DIMY,BLOCK_DIMZ);
  printf("init=%f, host_comp=%f, host2gpu=%f, gpu_comp=%f, gpu2host=%f, tot=%f \n", 
	 init, host_comp, host2gpu, gpu_comp, gpu2host, tot);
  printf("Stencil Throughput: %f Gpts/s\n", (1.0e-6*points)/gpu_comp); // gpu_comp is measured in ms
  printf("gFlops = %f GFLOPs\n", gFlops);

  free(h_a);
  free(h_gold_a);

  printf("\n");
  return 0;
}
