CFLAGS :=  -ggdb -Wall
CC := gcc
EXE = artistAnt

OBJS = ant_engine.o artist_ant.o

#all: ant_engine.o artist_ant.o artistAnt

artistAnt:ant_engine.o artist_ant.o
		@$(CC) $(CCFLAGS) -o $(EXE) $(OBJS) paint.S

tp1:ant_engine.o artist_ant.o
		@$(CC) $(CCFLAGS) -g $(OBJS) paint.S

ant_engine.o: ant_engine.h
		$(CC) $(CFLAGS) -c ant_engine.c  $(LIB)

artist_ant.o: artist_ant.h
		$(CC) $(CFLAGS) -c artist_ant.c  $(LIB)


clean:
		rm -f $(EXE) $(OBJS) core

.PHONY: clean all
