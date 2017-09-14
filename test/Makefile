DAWNCC = "/home/alyson/git/dawncc/lib"
#ST = "../../lib/libLLVMScopeTree.so" 
#AI = "../lib/libLLVMArrayInference.so"
STENCIL = "../build/src/libMyPass.so"
PRA = "${DAWNCC}/PtrRangeAnalysis/libLLVMPtrRangeAnalysis.so"
INPUT = "stencil"

all: pskelcc
	clang -g -S -emit-llvm -c ${INPUT}.c -o ${INPUT}-base.ll
	opt -S -mem2reg -instnamer ${INPUT}-base.ll -o ${INPUT}.ll
	#llc opt-hello.bc -filetype=obj -o opt-hello.o
	#gcc opt-hello.o -o hello -lm

pass: stencil.ll
	opt -load ${PRA} -load ${STENCIL} -stencil -stats ${INPUT}.ll -S -disable-output

stencil: ../src/Stencil.cpp ../src/Stencil.h
	make -C ../build

clean:
	rm stencil.ll stencil-base.ll
