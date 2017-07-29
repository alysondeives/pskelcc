-include ../../common/options.mk

SRC = $(wildcard *.c)
OBJS = $(basename $(SRC))

all: $(SRC) pskelcc
	clang -g -S -emit-llvm -c $(SRC) -o ${OBJS}-base.ll
	opt -S -mem2reg -instnamer ${OBJS}-base.ll -o ${OBJS}.ll
	opt -load ${PRA} -load ${STENCIL} -stencil -stats ${OBJS}.ll -S -disable-output

clean:
	rm ${OBJS}.ll ${OBJS}-base.ll



