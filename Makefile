CFLAGS :=  -ggdb -Wall
CC := gcc
EXE = qsort

OBJS = main.o qsort.o

all: main.o qsort.o qsort

qsort:
		$(CC) $(CCFLAGS) -o $(EXE) $(OBJS)

main.o:main.c qsort2.h
		$(CC) $(CCFLAGS) -c -o main.o main.c 


qsort.o:qsort.S qsort2.c qsort2.h
		$(CC) -g -DUSE_QSORT -c -o qsort.o qsort.S   || $(CC) -g -std=c99 -c -o qsort.o qsort2.c

clean:
		rm -f $(EXE) $(OBJS) core

.PHONY: clean all
