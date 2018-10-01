#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>

#include <unistd.h>

extern size_t qsort();//TODO: Definir parametros


void print_help(){
  //TODO: Que mensaje de ayuda vamos a dar
  printf("Imprimo la ayuda.\n");
}

void print_version(){
  //TODO: Nose a que se refiere con eso
  printf("Imprimo la version.\n");
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
    return qsort();
}
