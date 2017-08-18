POLYBENCH=/home/alyson/git/pskelcc/benchmarks/PPCG

all: polybench ppcg

polybench:  ${POLYBENCH}/utilities/polybench.c
    nvcc -O3 -arch=sm_35 -x c++ -c ${POLYBENCH}/utilities/polybench.c -o ${POLYBENCH}/utilities/polybench.o

ppcg: $(SRC) ${POLYBENCH}/utilities/polybench.o
    ppcg $(SRC) -DPOLYBENCH_USE_C99_PROTO -I ${POLYBENCH}/utilities/ --dump-sizes
    nvcc -O3 -arch=sm_35  -I ${POLYBENCH}/utilities/ ${POLYBENCH}/utilities/polybench.o  ${OBJS}_host.cu ${OBJS}_kernel.cu -o ${OBJS}

    
        
