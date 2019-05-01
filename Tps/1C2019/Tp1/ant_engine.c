#include "ant_engine.h"
#include "ant_constants.h"
#include "artist_ant.h"
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void filter_ch_index(char string[], int result[], char ch);


void*
make_rules(char *spec)
{

	int len = strlen(spec);
	int size;

	if(len % 2 == 0){
		size = (len/2)+1;
	}else{
		size = (len/2)+2;
	}

	int *rules = malloc(size * sizeof(int));

	filter_ch_index(spec,rules, '|');

	for(int i = 0; i < size; i++){
		switch(rules[i]){
			case 'L':
				rules[i] = RL;
				break;
			case 'R':
				rules[i] = RR;
				break;
		}
	}
  return rules;
}

void*
make_palette(unsigned char *colours)
{
  	int len = strlen((const char *)colours);

  	int size;

	if(len % 2 == 0){
		size = (len/2)+1;
	}else{
		size = (len/2)+2;
	}

	int *palette = malloc(size * sizeof(int));

	filter_ch_index((char *)colours,palette, '|');

	for(int i = 0; i < size; i++){
		switch(palette[i]){
			case 'R':
				palette[i] = CR;
				break;
			case 'G':
				palette[i] = CG;
				break;
			case 'B':
				palette[i] = CB;
				break;
			case 'Y':
				palette[i] = CY;
				break;
			case 'N':
				palette[i] = CN;
				break;
			case 'W':
				palette[i] = CW;
				break;
		}
	}

  return palette;
}

void filter_ch_index(char string[], int result[], char ch)
{
    int j = 0;

    for (int i = 0; string[i] != '\0'; i++)
    {
  		if (string[i] != ch){
	        result[j++] = string[i];
        }
    }
    result[j] = -1;
}
