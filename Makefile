.PHONY: all clean

all:
	as alloc.s -o alloc.o
	as io.s -o io.o
	as main.s -o main.o
	ld --entry main main.o alloc.o io.o -o program

clean:
	rm -f *.o program
