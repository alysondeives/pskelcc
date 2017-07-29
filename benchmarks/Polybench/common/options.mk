# DawnCC libraries
DAWNCC = "/home/alyson/git/dawncc/lib"
PSKELCC = "/home/alyson/git/pskelcc"
PRA = "${DAWNCC}/PtrRangeAnalysis/libLLVMPtrRangeAnalysis.so"

# PSkelCC library
STENCIL = "${PSKELCC}/build/src/libMyPass.so"

# Build PSkelCC
pskelcc:
	make -C ${PSKELCC}/build
