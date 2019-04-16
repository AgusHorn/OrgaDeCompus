CFLAGS :=  -ggdb -Wall
CC := gcc
EXE = artistAnt

OBJS = ant_engine.o artist_ant.o

all: ant_engine.o artist_ant.o artistAnt

artistAnt:
		@$(CC) $(CCFLAGS) -o $(EXE) $(OBJS)

clean:
		rm -f $(EXE) $(OBJS) core

.PHONY: clean all
