CC=gcc
CFLAGS=-g -std=c99 -Wall -Wtype-limits -pedantic -Wconversion -Wno-sign-conversion

OBJ = cache.o main.o

main: cache.o main.o
	$(CC) $(CFLAGS) -o main $(OBJ)

cache.o: cache.h cache.c
	$(CC) $(CFLAGS) -c cache.c

main.o:main.c
	$(CC) $(CFLAGS) main.c -c

.PHONY: clean
clean:
	rm -rf main *.o
