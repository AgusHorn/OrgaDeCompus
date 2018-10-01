#include <stdio.h>
#include <string.h>

#include "qsort2.h"

void swap (char** x, char** y) {
	char* auxiliar = *x;
	*x = *y;
	*y = auxiliar;
}

int pivotear(char** ini_arreglo, int inicio, int fin){
    int pivote;
    char* valor_pivote;
    char* aux;

    pivote = inicio;//elegimos pivote izquierdo, se puede cambiar eventualmente.
    valor_pivote = ini_arreglo[pivote];
    for (int i=inicio+1; i<=fin; i++){
        if (strcmp(ini_arreglo[i], valor_pivote) < 0){
                pivote++;
                swap(&ini_arreglo[i],&ini_arreglo[pivote]);

        }
    }
    aux=ini_arreglo[inicio];
    ini_arreglo[inicio]=ini_arreglo[pivote];
    ini_arreglo[pivote]=aux;
    return pivote;
}

size_t qsort(char** ini_arreglo, int inicio, int fin ){
  printf("estoy en el .c\n");
  if(inicio>fin)return 0;

  int pivot = pivotear(ini_arreglo,inicio,fin);

  qsort(ini_arreglo,inicio,pivot-1);
  qsort(ini_arreglo,pivot+1,fin);

  return 0;
}

/*int main(){
  char* hola[5] = {"d","a","e","b","c"};//ejemplito
  qsort(hola,0,4);
  for(int i=0;i<5;i++){
    printf("%s",hola[i]);
  }
  printf("\n");
  return 0;
}*/
