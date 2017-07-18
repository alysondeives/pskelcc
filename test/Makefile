DAWNCC = "/home/alyson/git/dawncc/lib"
#ST = "../../lib/libLLVMScopeTree.so" 
#AI = "../lib/libLLVMArrayInference.so"
STENCIL = "../build/src/libMyPass.so"
PRA = "${DAWNCC}/PtrRangeAnalysis/libLLVMPtrRangeAnalysis.so"

all:
	clang -g -S -emit-llvm -c 2DJacobi.c -o stencil-base.ll
	opt -S -mem2reg stencil-base.ll -o stencil.ll
	#llc opt-hello.bc -filetype=obj -o opt-hello.o
	#gcc opt-hello.o -o hello -lm

pass: stencil.ll
	opt -load ${PRA} -load ${STENCIL} -stencil stencil.ll -disable-output

stencil: ../src/Stencil.cpp ../src/Stencil.h
	make -C ../build

clean:
	rm stencil.ll stencil-base.ll
