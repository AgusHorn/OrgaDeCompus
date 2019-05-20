#include "cache.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>


#define BLOCKSIZE 64   //(Bytes)-| 
                       //        |--> Entonces hay 32 bloques
#define CACHESIZE 2048 //(Bytes)-|

#define ASOCIATIVITY 4 // Y por asociativity -> 32/4 = 8 sets

#define MEMSIZE 65536 // 64KB

typedef struct block {
    int priority; //para FIFO
    int tag;
    int valid;
    char bytes[BLOCKSIZE];
} block_t;

typedef struct set {
    int next_priority;
    block_t blocks[ASOCIATIVITY];
}set_t;


struct cache {
    set_t sets[8];
    int misses;
    int access;
};

//FUNCIONES AUXILIARES

bloque_t init_block(){
    bloque_t block;
    block.priority = 0;
    block.valid = 0;
    return block;
}

set_t init_set(){
  set_t set;
  set.next_priority = 1
  for(int i = 0; i < ASOCIATIVITY; i++){
    set.bloques[i].valid = 0;
    set.bloques[i].priority = 0;
  }
  return set;
}

cache_t cache;

char memoria[MEMSIZE];

//PRIMITIVAS DE LA SIMULACION

void init(){
    cache.misses = 0;
    cache.access = 0;
    for(int i = 0; i < 8; i++){
        cache.sets[i] = init_set();
    }
}

/* CACHE ADDRESS:
 *  ______________________________
 * |   TAG   |  INDEX  |  OFFSET |
 *  ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬
 * 15       9|8       6|5       0|
 */

unsigned int get_offset (unsigned int address){
  return (address & 0xFFC0);
}

int get_tag(int address){
  return (address) >> 9;
}

int find_set(int address){
    return (address & 0x0380) >> 6;
}

int is_hit(int setnum, int tag){
  for(int i = 0; i<ASOCIATIVIDAD; i++){
    if(cache.sets[setnum].bloques[i].valid == 1 && cache.sets[setnum].bloques[i].tag == tag){
      return i;
    }
  }
  return -1;
}

unsigned int select_oldest(unsigned int setnum){
  int set = cache.sets[setnum];
  int way = 5; //Empieza en 5 porque al ser ASOC = 4, nunca va a haber un priority mayor.
  for(int i = 0; i < ASOCIATIVIDAD; i++){
    if(set.bloques[i].priority < way){
      way = i;
    }
  }
  return way;
}


//Lee el bloque blocknum de memoria y lo guarda en el conjunto
//y vı́a indicados en la memoria caché.
void read_tocache(unsigned int blocknum, unsigned int way, unsigned int set){
  
}


//Escribe el char en la dirección address de caché??
void write_tocache(unsigned int address, unsigned char){

}

int read_byte(int address){
  if(address<0 || address>MEMSIZE){
    printf("Error: Direccion de memoria inválida.\n");
    return -1; //ERROR, TODO:Setear el errno
  }
  int tag = get_tag(address);
  int setnum = find_set(address);
  int offset = get_offset(address);

  int way = is_hit(setnum, tag);
  cache.access++;

  char value;
  if (way != -1){ //es un HIT!
    value = cache.sets[setnum].bloques[way].bytes[offset];
  }else{ //es un miss :(
    cache.misses++;
    value = memoria[address];
    read_tocache(((tag << 9) | (setnum << 6))/BLOCKSIZE, way, setnum); //Llevo bloque a la caché.
  }
  return (0xFF & (int)value); //TODO: revisar este &
}

int write_byte(int address, char value){
  if(address<0 || address>MEMSIZE){
    return -1; //ERROR, TODO:Setear el errno
  }

  int tag = get_tag(address);
  int setnum = find_set(address);
  int offset = get_offset(address);
  int way = is_hit(setnum, tag);
  cache.access++;

  if(way != -1){ //es un HIT!
    cache.sets[setnum].bloques[way].bytes[offset] = value;
    memoria[address] = value;
  } else{  //es un miss:(
    cache.misses++;
    memoria[address] = value;
  }
  return (0xFF & (int)value); //TODO: revisar este &
}

//Devuelve el porcentaje de misses.
int get_miss_rate(){
  if(cache.misses == 0 || cache.access == 0) return 0;
  return (cache.misses*100/cache.access);
}
