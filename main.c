#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#define _POSIX_C_SOURCE 200809L //getline

#ifdef USE_QSORT
extern void qsort2(char** izq, char** der, int num);//TODO: Definir parametros
#else
#include "qsort2.h"//para usar la version de c.
#endif

//Imprime por salida estandar el mensaje de ayuda.
void print_help(){
  printf("Usage:\n\
\tqsort -h\n\
\tqsort -V\n\
\tqsort [options] archivo\n\
Options:\n\
\t-h, --help\t\
Imprime ayuda.\n\
\t-V, --version\t Versión del programa.\n\
\t-o, --output\t\
Archivo de salida.\n\
\t-n, --numeric\t Ordenar los datos numéricamente en vez de alfabéticamente.\n\
Examples:\n\
\tqsort -n numeros.txt\n");
}

void print_version(){
  //TODO: Nose a que se refiere con version
  printf("Imprimo la version.\n");
}

size_t contar_lineas(char* input){
  FILE* archivo = fopen(input,"r");
	if(!archivo){
    fprintf (stderr,"Error al tratar de abrir archivo.\n");
    return 0;//fallo
  }
  size_t lineas = 0;
  char* linea = NULL; size_t capacidad = 0; ssize_t leidos;

  while((leidos = getline(&linea,&capacidad,archivo)) > 0){
    lineas++;
  }
  free(linea);
  fclose(archivo);
  return lineas;
}

char** cargar_archivo(char* input, size_t cant){

  char** array = malloc(cant * sizeof(char*));

  if(!array){
    fprintf (stderr,"Error al pedir memoria para el arreglo.\n");
    return 0;
  }

  FILE* archivo = fopen(input,"r");
	if(!archivo){
    fprintf (stderr,"Error al tratar de abrir archivo.\n");
    return 0;//fallo
  }

  char* linea = NULL; size_t capacidad = 0; ssize_t leidos;
  size_t i = 0;
  while((leidos = getline(&linea,&capacidad,archivo)) > 0){
    array[i] = strdup(linea);
    i++;
  }

  free(linea);
  fclose(archivo);
  return array;
}



bool escribir_archivo(char** array, size_t n, char* output){
  FILE* archivo;
  if(strcmp(output,"-")== 0){
    archivo = stdout;
  }
  else{
      archivo = fopen(output,"w");
  }
  if(!archivo){
    fprintf (stderr,"Error al tratar de abrir archivo output.\n");
    return false;//fallo
  }
  for(size_t i = 0; i<n; i++ ){
    fputs(array[i],archivo);
  }
  return true;
}


int main(int argc, char *argv[]){

  char *output = NULL;
  bool numeric = false;
  int c;

  while ((c = getopt (argc, argv, "hVo:n")) != -1){
    switch (c){

      case 'h':
        print_help();
        return 0;
      case 'V':
        print_version();
        return 0;
      case 'o':
        output = optarg;//TODO: Si output=='-' se debe imprimir por stdout.
        printf("output file is %s.\n",output);
        break;
      case 'n':
        numeric = true;
        break;
      case '?': //opcion desconocida
        if (optopt == 'o')//si no le dan parametro a la opcion de output
          fprintf (stderr, "Option -%c requires an argument.\n", optopt);
        else if (isprint (optopt))
          fprintf (stderr, "Unknown option `-%c'.\n", optopt);
        else
          fprintf (stderr,"Unknown option character `\\x%x'.\n",optopt);
        return 1;
      }
    }

    size_t cant_lineas = contar_lineas(argv[argc-1]);
    char** array_lineas = cargar_archivo(argv[argc-1],cant_lineas);
    if(!array_lineas){
      //TODO:mensaje de error
      return 1;
    }
    int n = 0;
    if(numeric){
      n = 1;
    }
    qsort2(&array_lineas[0],&array_lineas[cant_lineas-1],n);
    bool escribio = escribir_archivo(array_lineas, cant_lineas,output);
    if(!escribio){
      fprintf (stderr,"Error al escribir el archivo de output.\n");
      return 1;
    }
    free(array_lineas);
    return 0;
}
