#ifndef __PAINT_H__
#define __PAINT_H__

#include <unistd.h>
#include <stdint.h>
#include <stdio.h>

void* paint(void *ant, void *grid, void *palette, void *rules,  uint32_t iterations);


#endif /* __PAINT_H__ */
