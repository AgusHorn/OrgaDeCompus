CFLAGS :=  -ggdb -Wall
CC := gcc
EXE = qsort

OBJS = main.o qsort.o

all: main.o qsort.o qsort

qsort:
		$(CC) $(CCFLAGS) -o $(EXE) $(OBJS)

main.o:main.c qsort2.h
		$(CC) -c -o main.o main.c $(CCFLAGS)


qsort.o:qsort.S qsort2.c qsort2.h
		$(CC) -c -o qsort.o qsort.S -DUSE_QSORT $(CCFLAGS) || $(CC) -c -o qsort.o qsort2.c $(CCFLAGS)

clean:
		rm -f $(EXE) $(OBJS) core

.PHONY: clean all
