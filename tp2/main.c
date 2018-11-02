#define _GNU_SOURCE
#define _POSIX_C_SOURCE 200809L //getline

#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>


#include "cache.h"

//TODO: Medir tiempos de ejecucion para despues poder comparar.

void realizar_read(char* direccion){


   if(!direccion){
     printf("Falta la direccion de memoria a leer.\n");
     return;
   }

   //Habria que verificar que es realmente un numero.
   int address = atoi(direccion); //convierto la direccion en int

   printf("Read devuelve: %d\n", read_byte(address));
}


void realizar_write(char* direccion, char* valor){

  //Habria que verificar que es realmente un numero.
  int address = atoi(direccion);

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
      printf("Miss_rate es: %d\n", get_miss_rate());
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

  //TODO: iniciamos sistema
  init();

  if(!procesar_archivo(argv[1])){
    fprintf (stderr,"Error al procesar el archivo.\n");
    exit(EXIT_FAILURE);
  }


    return 0;
}
