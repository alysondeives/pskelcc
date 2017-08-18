#!/bin/bash

NVPROF="nvprof --metrics all"
TSTEPS=10

for SIZE in SMALL_DATASET STANDARD_DATASET LARGE_DATASET
do
  for KERNEL in 7 13 19 25 31
  do
    for OPT in ppcg ppcg-opt
    do 
      make DATASET=${SIZE} -C ../jacobi3d${KERNEL}pt
      BIN="../../bin/jacobi3d${KERNEL}pt-${OPT}"
        
      #save baseline execution output
      #${BIN}  &> ${KERNEL}pt_${OPT}_${SIZE}.exec

      #save baseline nvprof
      nvprof ${BIN} &> ${KERNEL}pt_${OPT}_${SIZE}.nvprof

      #save baseline nvprof metrics
      ${NVPROF} ${BIN} &> ${KERNEL}pt_${OPT}_${SIZE}.metrics
    done
  done
done


