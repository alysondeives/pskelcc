/* 
 * Implementation a Cloud dynamic simulation described in the following paper:
 * 
 * Alisson Rodrigo da Silva and Maury Meirelles Gouvêa, Jr.. 2010. 
 * Cloud dynamics simulation with cellular automata. 
 * In Proceedings of the 2010 Summer Computer Simulation Conference (SCSC '10). 
 * Society for Computer Simulation International, San Diego, CA, USA, 278-283.
 * 
 * Copyright 2017, Alyson Deives Pereira
 */
 
#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>

//#include <stdio.h>
//#include <unistd.h>
//#include <string.h>
//#include <math.h>

#define WIND_X_BASE	15
#define WIND_Y_BASE	12
#define DISTURB		0.1f
#define CELL_LENGTH	0.1f
#define CELL_LENGTH_INV 10.0f
#define K           0.0243f
#define K2	   0.006075f
#define DELTAPO     0.5f

/* Include polybench common header. */
#include "../common/common.h"


/* Convert Celsius to Kelvin */
float Convert_Celsius_To_Kelvin(float number_celsius){
	float number_kelvin;
	number_kelvin = number_celsius + 273.15f;
	return number_kelvin;
}

/* Convert Pressure(hPa) to Pressure(mmHg) */
float Convert_hPa_To_mmHg(float number_hpa){
	float number_mmHg;
	number_mmHg = number_hpa * 0.750062f;

	return number_mmHg;
}

/* Convert Pressure Millibars to mmHg */
float Convert_milibars_To_mmHg(float number_milibars){
	float number_mmHg;
	number_mmHg = number_milibars * 0.750062f;

	return number_mmHg;
}

/* Calculate RPV */
float CalculateRPV(float temperature_Kelvin, float pressure_mmHg){
	float realPressureVapor; //e
	float PsychrometricConstant = 6.7f * powf(10,-4); //A
	float PsychrometricDepression = 1.2f; //(t - tu) in ºC
	float esu = pow(10, ((-2937.4f / temperature_Kelvin) - 4.9283f * log10(temperature_Kelvin) + 23.5470f)); //10 ^ (-2937,4 / t - 4,9283 log t + 23,5470)
	realPressureVapor = Convert_milibars_To_mmHg(esu) - (PsychrometricConstant * pressure_mmHg * PsychrometricDepression);

	return realPressureVapor;
}

/* Calculate Dew Point */
float CalculateDewPoint(float temperature_Kelvin, float pressure_mmHg){
	float dewPoint; //TD
	float realPressureVapor = CalculateRPV(temperature_Kelvin, pressure_mmHg); //e
	dewPoint = (186.4905f - 237.3f * log10(realPressureVapor)) / (log10(realPressureVapor) -8.2859f);

	return dewPoint;
}

/* Wind Array initialization. */
void init_wind (int ni, int nj, DATA_TYPE* A, DATA_TYPE* B)
{
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++){
		A[i*nj + j] = (WIND_X_BASE - DISTURB) + (DATA_TYPE)rand()/RAND_MAX * 2 * DISTURB;
		B[i*nj + j] = (WIND_Y_BASE - DISTURB) + (DATA_TYPE)rand()/RAND_MAX * 2 * DISTURB;	
    }
}

void init_array(int ni, int nj, DATA_TYPE *A, DATA_TYPE *B){
	int i, j, y, x0 = nj/2, y0 = ni/2;
	int raio_nuvem = 20; 					//atoi(argv[4]);
	DATA_TYPE temperaturaAtmosferica = -3.0f; 	//atof(argv[5]);
	//alturaNuvem = 5.0; 				//atof(argv[6]);
	DATA_TYPE pressaoAtmosferica =  700.0f;		//atof(argv[7]);
	DATA_TYPE deltaT = 0.001f;					//atof(argv[8]);
	
	DATA_TYPE pontoOrvalho = CalculateDewPoint(Convert_Celsius_To_Kelvin(temperaturaAtmosferica), Convert_hPa_To_mmHg(pressaoAtmosferica));
	DATA_TYPE limInfPO = pontoOrvalho - DELTAPO;
	DATA_TYPE limSupPO = pontoOrvalho + DELTAPO;
	
	srand(1);
	for (i = 0; i < ni; i++){
		for (j = 0; j < nj; j++){
			A[i*nj + j] = temperaturaAtmosferica;
			B[i*nj + j] = temperaturaAtmosferica;
		}
	}
	
	for(i = x0 - raio_nuvem; i < x0 + raio_nuvem; i++){
		 // Equação da circunferencia: (x0 - x)² + (y0 - y)² = r²
		y = (int)((floor(
			sqrt( pow((DATA_TYPE)raio_nuvem, 2.0) - pow(((DATA_TYPE)x0 - (DATA_TYPE)i), 2))
			- y0) * -1));
		for(j = y0 + (y0 - y); j >= y; j--){
			A[i*nj + j] = limInfPO + (DATA_TYPE)rand()/RAND_MAX * (limSupPO - limInfPO);
			//B[i*nj + j] = limInfPO + (float)rand()/RAND_MAX * (limSupPO - limInfPO);
		}
	}
	
}

/* Main computational kernel. The whole function will be timed,
   including the call and return. */
void cloudsim(int tsteps, int ni, int nj, DATA_TYPE *A, DATA_TYPE *B, DATA_TYPE *WIND_X, DATA_TYPE *WIND_Y)
{
	int t, i, j, c, w, e, n, s, xfactor, yfactor;
	int numNeighbor = 4;
	
	DATA_TYPE deltaT = 0.001f;
	DATA_TYPE temperatura_conducao = 0.0f;
	DATA_TYPE sum = 0.0f;
	DATA_TYPE temperaturaNeighborX;
	DATA_TYPE temperaturaNeighborY;
	DATA_TYPE componenteVentoX;
	DATA_TYPE componenteVentoY;
	DATA_TYPE temp_wind;
	DATA_TYPE result;
	DATA_TYPE xwind, ywind;
	
	for (t = 0; t < _PB_TSTEPS; t++) {
		for (i = 0; i < _PB_NI; i++) {
			for (j = 0; j < _PB_NJ; j++) {
				numNeighbor = (j == 0) ? numNeighbor-1 : numNeighbor;
				numNeighbor = (i == 0) ? numNeighbor-1 : numNeighbor;
				numNeighbor = (j == _PB_NJ-1) ? numNeighbor-1 : numNeighbor;
				numNeighbor = (i == _PB_NI-1) ? numNeighbor-1 : numNeighbor;
				
				c = i * _PB_NJ + j;
				w = (j == 0)        ? c : c - 1;
				e = (j == _PB_NJ-1) ? c : c + 1;
				n = (i == 0)        ? c : c - _PB_NI;
				s = (i == _PB_NI-1) ? c : c + _PB_NI;
				
				sum = 4 * A[c] - ( A[n] + A[w] + A[e] + A[s]);
				
				temperatura_conducao = -K*(sum / numNeighbor) * deltaT;
	
				result = A[c] + temperatura_conducao;
				
				xwind = WIND_X[i*_PB_NJ+j];
				ywind = WIND_Y[i*_PB_NJ+j];
				
				temperaturaNeighborX = (xwind>0) ? A[e] : A[w];
				temperaturaNeighborY = (ywind>0) ? A[s] : A[n];
				
				xfactor = (xwind>0) ? 1 : -1;
				yfactor = (ywind>0) ? 1 : -1;

				//temperaturaNeighborX = A[(ni+yfactor) * _PB_NJ + nk];
				//temperaturaNeighborY = A[ni*_PB_NJ + (nj+xfactor)];
				componenteVentoX = xfactor * xwind;
				componenteVentoY = yfactor * ywind;
				
				temp_wind = (-componenteVentoX * ((A[c] - temperaturaNeighborX)/CELL_LENGTH)) -  
				            ( componenteVentoY * ((A[c] - temperaturaNeighborY)/CELL_LENGTH));
				
				B[i * _PB_NJ + j] = result + ((numNeighbor==4)?(temp_wind*deltaT):0.0f);
			}
		}
					
		for (i = 0; i < _PB_N; i++)
			for (j = 0; j < _PB_N; j++)
				A[i*_PB_N + j] = B[i*_PB_N + j];
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
   
  DATA_TYPE* WIND_X; 
  DATA_TYPE* WIND_Y;  
	
  A = (DATA_TYPE*)malloc(ni*nj*sizeof(DATA_TYPE));
  B = (DATA_TYPE*)malloc(ni*nj*sizeof(DATA_TYPE));

  WIND_X = (DATA_TYPE*)malloc(ni*nj*sizeof(DATA_TYPE));
  WIND_Y = (DATA_TYPE*)malloc(ni*nj*sizeof(DATA_TYPE));

  /* Initialize array(s). */
  init_array(ni,nj, A, B);
  init_wind (ni, nj, WIND_X, WIND_Y);

  /* Start timer. */
  t_start = rtclock();

  /* Run kernel. */
  cloudsim(tsteps, ni,nj, A, B, WIND_X, WIND_Y);

  /* Stop and print timer. */
  t_end = rtclock();
  fprintf(stdout, "CPU Runtime: %0.6lfs\n", t_end - t_start);

  /* Be clean. */
  free(A);
  free(B);
  free(WIND_X);
  free(WIND_Y);
  return 0;
}
