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

//Devuelve el offset del byte del bloque de memoria que
//mapea la dirección address.
unsigned int get_offset (unsigned int address);

//Devuelve el conjunto al que mapea la direccion
//address.
int find_set(int address);

//Devuelve la vı́a en la que está el bloque más “viejo”
//dentro de un conjunto, utilizando el campo correspondiente de
//los metadatos de los bloques del conjunto.
unsigned int select_oldest(unsigned int setnum);

//Lee el bloque blocknum de memoria y lo guarda en el conjunto
//y vı́a indicados en la memoria caché.
void read_tocache(unsigned int blocknum, unsigned int way, unsigned int set);

//Escribe el char en la dirección address de caché??
void write_tocache(unsigned int way,unsigned int index,unsigned int offset, unsigned char value);

//Busca el valor del byte correspondiente a la posición address
//en la caché; si éste nose encuentra en la caché debe cargar
//ese bloque. El valor de retorno siempre debe ser el valor del byte almacenado en la dirección indicada.
int read_byte(int address);

//Escribe el valor value en la posición address de memoria,
//y en la posición correcta del bloque que corresponde a address,
//si el bloque se encuentra en la caché. Si no se encuentra, debe escribir
//el valor solamente en la memoria.
int write_byte(int address, char value);

//Devuelve el porcentaje de misses.
int get_miss_rate();

#endif // CACHE_H
