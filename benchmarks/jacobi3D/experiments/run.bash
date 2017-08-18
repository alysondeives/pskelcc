#!/bin/bash

NVPROF="nvprof --metrics all"
TSTEPS=10

for SIZE in 64 128 256
do
  for KERNEL in 7 13 19 25 31
  do
    for OPT in 27
    do
      BIN="../bin/jacobi3d${KERNEL}pt"
        
      #save baseline execution output
      ${BIN} ${OPT} ${SIZE} ${SIZE} ${SIZE} ${TSTEPS} &> ${KERNEL}pt_${OPT}_${SIZE}.exec

      #save baseline nvprof
      nvprof ${BIN} ${OPT} ${SIZE} ${SIZE} ${SIZE} ${TSTEPS} &> ${KERNEL}pt_${OPT}_${SIZE}.nvprof

      #save baseline nvprof metrics
      ${NVPROF} ${BIN} ${OPT} ${SIZE} ${SIZE} ${SIZE} ${TSTEPS} &> ${KERNEL}pt_${OPT}_${SIZE}.metrics    
    done
  done
done


