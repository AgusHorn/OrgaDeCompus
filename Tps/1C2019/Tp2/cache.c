#include "cache.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>


#define BLOCKSIZE 64   //(Bytes)-|
                       //        |--> Entonces hay 32 bloques
#define CACHESIZE 2048 //(Bytes)-|

#define BLOCKSSET  8

#define NWAYS 4

#define MEMSIZE 65536 // 64KB

typedef struct block {
    int priority; //para FIFO
    int tag;
    int valid;
    char bytes[BLOCKSIZE];
} block_t;

typedef struct set {
    int next_priority;
    block_t blocks[BLOCKSSET];
}set_t;


struct cache {
    set_t sets[NWAYS];
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
  for(int i = 0; i < BLOCKSSET; i++){
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
    for(int i = 0; i < NWAYS; i++){
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
  return (address & 0x003F);
}

int get_tag(int address){
  return (address) >> 9;
}

int get_index(int address){
    return (address & 0x0380) >> 6;
}

bool is_hit(int index, int tag, int* way){
  for(int i = 0; i<NWAYS; i++){
    if(cache.sets[i].bloques[index].valid == 1 && cache.sets[i].bloques[index].tag == tag){
        *way = i;
      return true;
    }
  }
  return false;
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
  cache.sets[way].blocks[set].bytes = memoria[blocknum];

}


//Escribe el char en la dirección address de caché??
void write_tocache(unsigned int way,unsigned int index,unsigned int offset, unsigned char* value){
  cache.sets[way].blocks[index].bytes[offset] = value

}

int read_byte(int address){
  if(address<0 || address>MEMSIZE){
    printf("Error: Direccion de memoria inválida.\n");
    return -1; //ERROR, TODO:Setear el errno
  }
  int tag = get_tag(address);
  int index = get_index(address);
  int offset = get_offset(address);
  int way;
  bool hit = is_hit(index, tag, &way);
  cache.access++;


  if (hit){ //es un HIT!
    value = cache.sets[way].bloques[index].bytes[offset];
  }else{ //es un miss :(
    cache.misses++;

    read_tocache(address,way,index); //Llevo bloque a la caché.
  }
  return (0xFF & (int)cache.sets[way].blocks[set].bytes)); //TODO: revisar este &
}

int write_byte(int address, char value){
  if(address<0 || address>MEMSIZE){
    return -1; //ERROR, TODO:Setear el errno
  }

  int tag = get_tag(address);
  int index = get_index(address);
  int offset = get_offset(address);
  int way;
  bool hit = is_hit(index, tag, &way);
  cache.access++;

  if(hit ){ //es un HIT!
    write_tocache(way,index,offset,value)
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
