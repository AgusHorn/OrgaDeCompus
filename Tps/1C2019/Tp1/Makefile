CFLAGS :=  -ggdb -Wall
CC := gcc
EXE = Tp1-C
EXE-ASM = Tp1-ASM

OBJS = ant_engine.o artist_ant.o paint.o
OBJS-ASM = ant_engine.o artist_ant.o


Tp1-C:ant_engine.o artist_ant.o paint.o
		@$(CC) $(CCFLAGS) -o $(EXE) $(OBJS)

Tp1-ASM:ant_engine.o artist_ant.o
		@$(CC) $(CCFLAGS) -o $(EXE-ASM) $(OBJS-ASM) paint.S


Tp1-GDB:ant_engine.o artist_ant.o
		@$(CC) $(CCFLAGS) -g $(OBJS)

ant_engine.o: ant_engine.h
		$(CC) $(CFLAGS) -c ant_engine.c  $(LIB)

artist_ant.o: artist_ant.h
		$(CC) $(CFLAGS) -c artist_ant.c  $(LIB)

paint.o:paint.h
		$(CC) $(CFLAGS) -c paint.c  $(LIB)


clean:
		rm -f $(EXE) $(EXE-ASM) $(OBJS) a.out

.PHONY: clean all
