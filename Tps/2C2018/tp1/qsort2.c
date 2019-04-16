#include <stdio.h>
#include <string.h>
#include <stdlib.h>


void swap (char** x, char** y) {
	char* auxiliar = *x;
	*x = *y;
	*y = auxiliar;
}

char** pivotear(char** izq, char** der, int num){
    char** pivote;
    char* valor_pivote;
    pivote = izq;//elegimos pivote izquierdo, se puede cambiar eventualmente.
    valor_pivote = *pivote;
    int i;
    for(i=1; izq+i <= der; i++){

      if(num == 0 && strcmp(*(izq+i), valor_pivote) < 0){
        swap(izq+i,pivote);
        swap(izq+i,pivote+1);
        pivote++;
      }

      if(num != 0){//comparacion numerica
        int a = atoi(*(izq+i));
        int b = atoi(valor_pivote);
        if(a < b){
          swap(izq+i,pivote);
          swap(izq+i,pivote+1);
          pivote++;
        }
      }
    }
    return pivote;
}

void qsort2(char** izq, char** der, int num){
  if(izq>=der)return;
  char** pivot = pivotear(izq,der,num);

  qsort2(izq,pivot-1,num);

  qsort2(pivot+1,der,num);

}
