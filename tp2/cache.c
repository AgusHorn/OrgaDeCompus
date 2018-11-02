#include "cache.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define BLOCKSIZE 64 //(en bytes)

#define MEMSIZE 65536 //(en bytes)

#define ASOCIATIVIDAD 4

typedef struct bloque {
    int num_access; //para el lru
    int tag;
    int dirty;
    int valid;
    char bytes[BLOCKSIZE];
} bloque_t;

typedef struct set {
    bloque_t bloques[ASOCIATIVIDAD];
    int count;//para el lru
}set_t;


struct cache {
    //bloque_t* bloques;
    set_t sets[16];
    int misses;  // tasa de misses
    int access;
    //bloque_t ultimo que se accedio?
    //size_t capacidad;  //
};

//FUNCIONES AUXILIARES

bloque_t init_block(){
    bloque_t block;// = malloc(sizeof(bloque_t));

    /*block.bytes = malloc(sizeof(char)* 64);//CON LOS 6 BITS DEL OFFSET SACO LA PALABRA BUSCADA?

    if(!block.bytes)return NULL;*/

    block.num_access = 0;

    block.dirty = 0;//?

    block.valid = 0;

    return block;
}

set_t init_set(){
  set_t set;
  set.count = 0;

  for(int i = 0; i<ASOCIATIVIDAD ; i++){
    set.bloques[i].valid = 0;
    set.bloques[i].dirty = 0;
    set.bloques[i].num_access = 0;
  }
  return set;
}

cache_t* cache;

char memoria[MEMSIZE];



//PRIMITIVAS DE LA SIMULACION

void init(){
    cache = malloc(sizeof(cache_t));
    if(!cache) return;//TODO: Avisar error
    cache->misses = 0;
    cache->access = 0;
    //cache->sets = malloc(sizeof(set_t)*16);//16 conjuntos de 4 bloques cada uno

    //if(!cache->sets)return NULL;

    for(int i = 0; i<16; i++){
        cache->sets[i] = init_set();
    }

    //memoria = malloc(sizeof(int)*65535);//cantidad de words en memoria
}

int find_set(int address){
    return (address & 0x0360) >> 6;
}

int find_lru(int setnum){
    int lru = cache->sets[setnum].count;
    int way;
    for(int i = 0; i<ASOCIATIVIDAD; i++){
      if(cache->sets[setnum].bloques[i].num_access <= lru){
        way = i;
        lru = cache->sets[setnum].bloques[i].num_access;//siempre me quedo con el menor ("el ultimo accedido")
      }
    }
    return way;

}

int is_dirty(int way, int setnum){
    return cache->sets[setnum].bloques[way].dirty;
}

/*void free_memory(){
  free(memoria);
  for(int i = 0; i<16; i++){
    //TODO: CAPAZ NO ES NECESARIO LIBERAR LA MEMORIA Y SE PUEDE USAR TOdo ESTATICO
  }
}*/

int get_tag(int address){
  //printf("address es %d entonces tag es %d\n", address,(address) >> 10 );
  return (address) >> 10;
}

int is_hit(int setnum, int tag){
  for(int i = 0; i<ASOCIATIVIDAD; i++){
    if(cache->sets[setnum].bloques[i].valid == 1 && cache->sets[setnum].bloques[i].tag == tag){
      cache->sets[setnum].count++;//actualizo el contador del lru
      cache->sets[setnum].bloques[i].num_access = cache->sets[setnum].count;//actualizo el contador de lru
      return i;
    }
  }
  return -1;
}

//Leer el bloque pasado por parametro y guardarlo en la cache
void read_block(int blocknum){
  //printf("blocknum es %d\n", blocknum);
  int address = blocknum*BLOCKSIZE;//block size;
  int setnum = find_set(address);
  int tag = get_tag(address);

  bool habia_espacio = false;
  int i = 0;
  for(; i<ASOCIATIVIDAD; i++){
    if(cache->sets[setnum].bloques[i].valid == 0){
      //printf("Encontre un lugar vacio\n");
      memcpy(cache->sets[setnum].bloques[i].bytes,&memoria[address],BLOCKSIZE);
      cache->sets[setnum].bloques[i].valid = 1;
      cache->sets[setnum].bloques[i].tag = tag;
      cache->sets[setnum].count++;//actualizo el contador del lru
      cache->sets[setnum].bloques[i].num_access = cache->sets[setnum].count;//actualizo el contador de lru
      habia_espacio = true;
      return;
    }
  }
  if(!habia_espacio){//politica de reemplazo: LRU
    int way_last_used = find_lru(setnum);
    if(is_dirty(way_last_used,setnum)){ //tengo que reescribirlo en memoria porque cambio
      write_block(way_last_used, setnum);
    }
    memcpy(cache->sets[setnum].bloques[way_last_used].bytes,&memoria[address],BLOCKSIZE);
    cache->sets[setnum].bloques[way_last_used].valid = 1;
    cache->sets[setnum].bloques[way_last_used].dirty = 0;//lo restauro a cero
    cache->sets[setnum].bloques[way_last_used].tag = tag;
    cache->sets[setnum].count++;//actualizo el contador del lru
    cache->sets[setnum].bloques[way_last_used].num_access = cache->sets[setnum].count;//actualizo el contador de lru

  }
}


//Escribe los datos del bloque setnum  de la via way
void write_block(int way, int setnum){
  int tag = cache->sets[setnum].bloques[way].tag << 10;
  int index = setnum << 6;
  int address = tag | index;
  memcpy(cache->sets[setnum].bloques[way].bytes,&memoria[address],BLOCKSIZE);
}

int get_offset(int address){
  return address & 0xF;
}


//Devolver el valor correspondiente a la posicion address
int read_byte(int address){
  if(address<0 || address>MEMSIZE){
    return -1; //ERROR, TODO:Setear el errno
  }

  int tag = get_tag(address);
  int setnum = find_set(address);
  int offset = get_offset(address);
  int way = is_hit(setnum, tag);
  cache->access++;
  char value;
  if(way == -1){//miss
    cache->misses++;
    value = memoria[address];
    read_block(((tag << 10) | (setnum << 6))/BLOCKSIZE);//me traigo el bloque a la cache.
  }else{//hit
    value = cache->sets[setnum].bloques[way].bytes[offset];
  }
  return (0xFF & (int)value);
}


//Escribe value en la pos correcta del bloque correspondiente a address
int write_byte(int address, char value){

  if(address<0 || address>MEMSIZE){
    return -1; //ERROR, TODO:Setear el errno
  }

  int tag = get_tag(address);
  int setnum = find_set(address);
  int offset = get_offset(address);
  int way = is_hit(setnum, tag);
  cache->access++;
  if(way == -1){//miss
    cache->misses++;
    memoria[address] = value;
    read_block(((tag << 10) | (setnum << 6))/BLOCKSIZE);//me traigo el bloque a la cache.
    return (0xFF & (int)value);//cuando salio todo bien
  }

  cache->sets[setnum].bloques[way].bytes[offset] = value;
  cache->sets[setnum].bloques[way].dirty = 1;//la cache esta actualizada y la memoria no.

  return (0xFF & (int)value);//cuando salio todo bien, para extender sin sin signo

}


//Devuelve el porcentaje de misses.
int get_miss_rate(){
  return (cache->misses*100/cache->access);
}
