#ifndef CACHE_H
#define CACHE_H

#include <stdlib.h>
#include <stdbool.h>

/* *****************************************************************
 *                DEFINICION DE LOS TIPOS DE DATOS
 * *****************************************************************/



/* *****************************************************************
 *                    PRIMITIVAS DE LA CACHE
 * *****************************************************************/

void init();

int find_set(int address);

int find_lru(int setnum);

int is_dirty(int way, int setnum);

void read_block(int blocknum);

void write_block(int address);

int read_byte(int address);

int write_byte(int address, char value);

int get_miss_rate();



#endif // CACHE_H
