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


long counter;

typedef struct block {
    long priority; //para FIFO
    int tag;
    int valid;
    char bytes[BLOCKSIZE];
} block_t;

typedef struct way {

    block_t blocks[BLOCKSSET];
}way_t;


struct cache {
    way_t ways[NWAYS];
    int misses;
    int access;
};

//FUNCIONES AUXILIARES

block_t init_block(){
    block_t block;
    block.priority = 0;
    block.valid = 0;
    return block;
}

way_t init_way(){
  counter = 1;
  way_t way;
  for(int i = 0; i < BLOCKSSET; i++){
    way.blocks[i].valid = 0;
    way.blocks[i].priority = 0;
  }
  return way;
}

cache_t cache;

char memoria[MEMSIZE];

//PRIMITIVAS DE LA SIMULACION

void init(){

    cache.misses = 0;
    cache.access = 0;
    for(int i = 0; i < NWAYS; i++){
        cache.ways[i] = init_way();
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

unsigned int get_tag(int address){
  return (address) >> 9;
}

unsigned int get_index(int address){
    return (address & 0x0380) >> 6;
}

bool is_hit(int index, int tag, int* way){
  for(int i = 0; i<NWAYS; i++){
    if(cache.ways[i].blocks[index].valid == 1 && cache.ways[i].blocks[index].tag == tag){
        *way = i;
      return true;
    }
  }
  return false;
}

unsigned int select_oldest(unsigned int index){
  long priorityOld = cache.ways[0].blocks[index].priority;
  int way = 0;
  for(int i = 0; i < NWAYS; i++){
    if(cache.ways[i].blocks[index].priority < priorityOld  && cache.ways[i].blocks[index].valid && cache.ways[i].blocks[index].priority ){
      way = i;
    }
  }
  return way;
}


//Lee el bloque blocknum de memoria y lo guarda en el conjunto
//y vı́a indicados en la memoria caché.
void read_tocache(unsigned int blocknum, unsigned int way, unsigned int set){

  cache.ways[way].blocks[set].bytes[get_offset(blocknum)] = memoria[blocknum];
  cache.ways[way].blocks[set].priority = counter;
  cache.ways[way].blocks[set].tag = get_tag(blocknum);
  cache.ways[way].blocks[set].valid = 1;
  counter++;

}


//Escribe el char en la dirección address de caché??
void write_tocache(unsigned int way,unsigned int index,unsigned int offset, unsigned char value){

  cache.ways[way].blocks[index].bytes[offset] = value;

}

int read_byte(int address){
  if(address<0 || address>MEMSIZE){
    printf("Error: Direccion de memoria inválida.\n");
    return -1; //ERROR, TODO:Setear el errno
  }
  unsigned int tag = get_tag(address);
  unsigned int index = get_index(address);
  unsigned int offset = get_offset(address);
  int way;
  bool hit = is_hit(index, tag, &way);
  cache.access++;


  if (!hit){ //es un HIT!
    cache.misses++;
    way = select_oldest(index);
    read_tocache(address,way,index); //Llevo bloque a la caché.
  }
  return (0xFF & (int)cache.ways[way].blocks[index].bytes[offset]); //TODO: revisar este &
}

int write_byte(int address, char value){
  if(address<0 || address>MEMSIZE){
    return -1; //ERROR, TODO:Setear el errno
  }

  unsigned int tag = get_tag(address);
  unsigned int index = get_index(address);
  unsigned int offset = get_offset(address);
   int way;
  bool hit = is_hit(index, tag, &way);
  cache.access++;

  if(hit ){ //es un HIT!
    write_tocache(way,index,offset,value);
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
