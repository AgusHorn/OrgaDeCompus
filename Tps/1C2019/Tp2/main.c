#define _GNU_SOURCE
#define _POSIX_C_SOURCE 200809L //getline

#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <time.h>


#include "cache.h"

#define LAT 100 //en nanosegundos
#define BW 133 //Mhz con un ancho de bus de 1 word (16 bits)
#define BS 64 //en bytes
#define WS 2 //WORD SIZE EN BYTES


//TODO: Medir tiempos de ejecucion para despues poder comparar.

void realizar_read(char* direccion){


   if(!direccion){
     printf("Falta la direccion de memoria a leer.\n");
     return;
   }

   int address = atoi(direccion);//Convierto la direccion en int.
   if (address == 0 && direccion[0] == 0){ //Si no es una conversion valida devuelve 0.
     printf("Error en la dirección recibida.\n");
     return;
   }

   printf("Read devuelve: %d\n", read_byte(address));
}


void realizar_write(char* direccion, char* valor){

  int address = atoi(direccion);
  if (address == 0 && strcmp(direccion, "0,") != 0){ //Si no es una conversion valida devuelve 0.
    printf("Error en la dirección recibida.\n");
    return;
  }

  if(!valor){
    printf("Falta el valor a escribir.\n");
  }

  //TODO: No se como pasar el valor de char* a char
  unsigned int value = atoi(valor);//esto me toma solo el primer valor y vienen 3
  char valor_char = (char)value;
  printf("Write devuelve: %d\n",(unsigned int)write_byte(address, valor_char));
}


bool procesar_archivo(const char* nombre){
  FILE* archivo = fopen(nombre,"r");

  if(!archivo){
    fprintf (stderr,"Error al tratar de abrir archivo.\n");
    return false;
  }
  char* linea = NULL; size_t capacidad = 0; ssize_t leidos;

  while((leidos = getline(&linea,&capacidad,archivo)) > 0){
    if(strcmp(linea, "MR\n") == 0){
      float miss_rate = get_miss_rate();
      printf("Miss_rate es: %f\n", miss_rate);
      float t_miss = (float)(LAT + ((BS - WS)*1000 / (WS * BW)));
      printf("Tiempo de acceso promedio:  %d nanosegundos.\n",(int)(miss_rate*((int)t_miss)/100) );
    }
    char* comando = strtok(linea, " ");
    if(strcmp(comando, "R") == 0){
      char* direccion = strtok(NULL, " ");
      realizar_read(direccion);
    }
    if(strcmp(comando, "W") == 0){
      char* direccion = strtok(NULL, " ");
      if(!direccion){
        printf("Falta direccion de memoria en donde escribir.\n");
      }
      char* valor = strtok(NULL, " ");
      realizar_write(direccion, valor);
    }

  }

  free(linea);
  fclose(archivo);
  return true;
}


int main(int argc, char *argv[]){
  if (argc != 2){
    fprintf (stderr,"Cantidad de parámetros incorrecta.\n");
    exit(EXIT_FAILURE);
  }

  init();
  printf("el nombre del archivo es %s\n", argv[1]);
  if(!procesar_archivo(argv[1])){
    fprintf (stderr,"Error al procesar el archivo.\n");
    exit(EXIT_FAILURE);
  }


  exit(EXIT_SUCCESS);
}
