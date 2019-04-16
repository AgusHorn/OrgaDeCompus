#include "ant_engine.h"
#include "ant_constants.h"
#include "artist_ant.h"
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

ant_t* change_orientation(ant_t *ant, rotation_t rule);
ant_t* move_ant(ant_t *ant, square_grid_t *grid, rotation_t rule);
void filter_ch_index(char string[], int result[], char ch);
ant_t* beginning_ant(ant_t *ant);

void*
paint(void *ant1, void *grid1, void *palette1, void *rules1,  uint32_t iterations)
{

	ant_t* ant = (ant_t*)ant1;
	square_grid_t* grid = (square_grid_t*)grid1;
	rotation_t* rules = (rotation_t *)rules1;
	colour_t* palette = (colour_t*)palette1;

	while (iterations != 0){
		colour_t *p = palette;
		p++;
		ant = beginning_ant(ant);
		for(rotation_t* r = rules; *r != -1; r++){
			grid->grid[ant->x][ant->y] = *p;
			ant = change_orientation(ant,*r);
			ant = move_ant(ant, grid, *r);
			p++;
			if (*p == -1){
				*p = palette[0];
			}
		}
		--iterations;
	}
	free(rules);
	free(palette);
 	return grid;
}

ant_t* beginning_ant(ant_t *ant){
	ant->x = 1;
	ant->y = 1;
	ant->o = ON;
	return ant;
}

ant_t* move_ant(ant_t *ant, square_grid_t *grid, rotation_t rule){
	switch((int)ant->o){
		case ON:
			if (ant->x == grid->height -1){
				ant->x = 0;
			}else{
				ant->x++;
			}
			break;
		case OS:
			if (ant->x == 0){
				ant->x = grid->height -1;
			}else{
				ant->x--;
			}
			break;
		case OE:
			if (ant->y == grid->width -1){
				ant->y = 0;
			}else{
				ant->y++;
			}
			break;
		case OW:
			if (ant->y == 0){
				ant->y = grid->width -1;
			}else{
				ant->y--;
			}
			break;
	}
	return ant;
}


ant_t* change_orientation(ant_t *ant, rotation_t rule){
	switch((int)ant->o){
		case ON:
			if (rule == RL){
				ant->o = OW;
			}else{
				ant->o = OE;
			}
			break;
		case OS:
			if (rule == RL){
				ant->o = OE;
			}else{
				ant->o = OW;
			}
			break;
		case OE:
			if (rule == RL){
				ant->o = ON;
			}else{
				ant->o = OS;
			}
			break;
		case OW:
			if (rule == RL){
				ant->o = OS;
			}else{
				ant->o = ON;
			}
			break;
	}
	return ant;
}

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
