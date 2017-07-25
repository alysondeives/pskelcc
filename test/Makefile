DAWNCC = "/home/alyson/git/dawncc/lib"
#ST = "../../lib/libLLVMScopeTree.so" 
#AI = "../lib/libLLVMArrayInference.so"
STENCIL = "../build/src/libMyPass.so"
PRA = "${DAWNCC}/PtrRangeAnalysis/libLLVMPtrRangeAnalysis.so"

all:
	clang -g -S -emit-llvm -c jacobi.c -o jacobi-base.ll
	opt -S -mem2reg -instnamer jacobi-base.ll -o jacobi.ll
	#llc opt-hello.bc -filetype=obj -o opt-hello.o
	#gcc opt-hello.o -o hello -lm

pass: stencil.ll
	opt -load ${PRA} -load ${STENCIL} -stencil -stats jacobi.ll -S -o jacobi2.ll

stencil: ../src/Stencil.cpp ../src/Stencil.h
	make -C ../build

clean:
	rm stencil.ll stencil-base.ll
