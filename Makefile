CFLAGS :=  -ggdb -Wall
CC := gcc
EXE = main


OBJS = main.o qsort.o



all: main.o qsort.o main


main:
		$(CC) $(CCFLAGS) -o $(EXE) $(OBJS)

main.o:main.c
		$(CC) -c -o main.o main.c $(CCFLAGS)

qsort.o:qsort.S
		$(CC) -c -o qsort.o qsort.S $(CCFLAGS)


clean:
		rm -f $(EXE) $(OBJS) core

.PHONY: clean all
