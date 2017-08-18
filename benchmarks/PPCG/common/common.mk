POLYBENCH=/home/alyson/git/pskelcc/benchmarks/PPCG
BIN=${POLYBENCH}/bin

all: polybench ppcg_opt ppcg

polybench:  ${POLYBENCH}/utilities/polybench.c
	nvcc -O3 -arch=sm_35 -x c++ -c ${POLYBENCH}/utilities/polybench.c -o ${POLYBENCH}/utilities/polybench.o

ppcg_opt: $(SRC) ${POLYBENCH}/utilities/polybench.o
	ppcg -DPOLYBENCH_USE_C99_PROTO -D${DATASET} -I ${POLYBENCH}/utilities/ --sizes="{kernel[i] -> block[1,16,32]; kernel[i] -> tile[1,32,32]}" $(SRC)
	nvcc -O3 -arch=sm_35  -D${DATASET} -I ${POLYBENCH}/utilities/ ${POLYBENCH}/utilities/polybench.o  ${OBJS}_host.cu ${OBJS}_kernel.cu -o ${BIN}/${OBJS}-ppcg-opt

ppcg: $(SRC) ${POLYBENCH}/utilities/polybench.o
	ppcg -DPOLYBENCH_USE_C99_PROTO -D${DATASET} -I ${POLYBENCH}/utilities/ $(SRC)
	nvcc -O3 -arch=sm_35  -D${DATASET} -I ${POLYBENCH}/utilities/ ${POLYBENCH}/utilities/polybench.o  ${OBJS}_host.cu ${OBJS}_kernel.cu -o ${BIN}/${OBJS}-ppcg
        
