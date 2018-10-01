#include <stdio.h>
#include <string.h>


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
    for(int i=0; izq+i <= der; i++){
      if(num == 0 && strcmp(*(izq+i), valor_pivote) < 0){
        swap(izq+i,pivote);
        pivote++;
      }
      if(num != 0){
        //comparacion numerica
      }
    }
    return pivote;
}

void qsort(char** izq, char** der, int num){
  if(izq>der)return;
  char** pivot = pivotear(izq,der,num);

  qsort(izq,pivot-1,num);
  qsort(pivot+1,der,num);



}

/*int main(){
  char* hola[5] = {"a","c","d","b","e"};//ejemplito
  qsort(&hola[0],&hola[4],0);
  for(int i=0;i<5;i++){
    printf("%s",hola[i]);
  }
  printf("\n");
  return 0;
}*/
