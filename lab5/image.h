#include <stdio.h>
#include <stdlib.h>

#ifndef IMAGE
#define IMAGE

void rotate_image_c(void *, void *, int, int, int, int, int, double );

void work_image_asm(void *, void *, int, int, double );

void work_image_asmSSE(void *, void *, int, int);

#endif
