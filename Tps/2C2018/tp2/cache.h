#ifndef CACHE_H
#define CACHE_H

#include <stdlib.h>
#include <stdbool.h>

/* *****************************************************************
 *                DEFINICION DE LOS TIPOS DE DATOS
 * *****************************************************************/
typedef struct cache cache_t;


/* *****************************************************************
 *                    PRIMITIVAS DE LA CACHE
 * *****************************************************************/

//Inicializa bloques de la cache como invalidos.
//tasa de misses = 0.
void init();

//Devuelve el conjunto al que mapea la direccion
//address.
int find_set(int address);

//Devuelve el bloque menos reciencientemenes usado.
int find_lru(int setnum);

//Devuelve el estado del bit Dirty del bloque.
int is_dirty(int way, int setnum);

//Leer el bloque pasado por parametro y guardarlo en la cache
void read_block(int blocknum);

//Escribe los datos del bloque setnum  de la via way
void write_block(int way, int setnum);

//Devolver el valor correspondiente a la posicion address
int read_byte(int address);

//Escribe value en la pos correcta del bloque correspondiente a address
int write_byte(int address, char value);

//Devuelve el porcentaje de misses.
int get_miss_rate();



#endif // CACHE_H
