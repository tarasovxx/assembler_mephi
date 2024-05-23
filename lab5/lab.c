#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "image.h"

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STBI_ONLY_PNG

#include "stb_image.h"
#include "stb_image_write.h"

int main(int argc, char * argv[]){
	long png=0x0a1a0a0d474e5089;
	char buf[8];
	FILE * f;
	struct timespec t, t1, t2;
	void * imgfrom, * imgto;
	int x, y, n;
	if (argc!=4) {
		fprintf(stderr, "Usage: %s png_file c_result asm_result\n", argv[0]);
		return 1;
	}
	if ((f=fopen(argv[1], "r"))==NULL) {
		perror(argv[1]);
		return 1;
	}

	fread(buf, 1, sizeof(long), f);
	fclose(f);
	if (*(long *)buf!=png){
		fprintf(stderr, "%s - not correct signature png_file\n", argv[1]);
		return 1;
	}

	if ((imgfrom=stbi_load(argv[1], &x, &y, &n, 4))==NULL){
		fprintf(stderr, "%s - not correct png_file\n", argv[1]);
		return 1;
	}

	printf("Image loads: %d*%d pixels, %d channels\n", x, y, n);
	if (n<3){
		fprintf(stderr, "Image is already monochrome\n");
		free(imgfrom);
		return 1;
	}
	int angle;
	printf("PLease write angle:");
	scanf("%d", &angle);
	if (n==3)
		printf("Image doesn't have alpha channel. Added\n");
	n=4;
	if ((imgto=malloc(x*y*n))==NULL){
		fprintf(stderr, "Can't allocate memory for image\n");
		free(imgfrom);
		return 1;
	}
	printf("x: %d\ny: %d\n", x, y);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
	rotate_image_c(imgfrom, imgto, x, y, angle);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
	t.tv_sec=t2.tv_sec-t1.tv_sec;
	if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
		t.tv_sec--;
		t.tv_nsec+=1000000000;
	}
	printf("C: %ld.%09ld\n", t.tv_sec, t.tv_nsec);
	if (stbi_write_png(argv[2], x, y, n, imgto, x*n)==0)
		printf("Cannot write image_c to file\n");
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
	printf("x: %d\ny: %d\n", x, y);
	work_image_asm(imgfrom, imgto, x, y, angle);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
	t.tv_sec=t2.tv_sec-t1.tv_sec;
	if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
		t.tv_sec--;
		t.tv_nsec+=1000000000;
	}
	printf("Asm: %ld.%09ld\n", t.tv_sec, t.tv_nsec);
	if (stbi_write_png(argv[3], x, y, n, imgto, x*n)==0)
		printf("Cannot write image_asm to file\n");
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
	//work_image_asmSSE(imgfrom, imgto, x, y);
	//clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
	//t.tv_sec=t2.tv_sec-t1.tv_sec;
	//if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
	//	t.tv_sec--;
	//	t.tv_nsec+=1000000000;
	//}
	//printf("AsmSSE: %ld.%09ld\n", t.tv_sec, t.tv_nsec);
	//if (stbi_write_png(argv[4], x, y, n, imgto, x*n)==0)
	//	printf("Cannot write image_asmSSE to file\n");
	free(imgfrom);
	free(imgto);
	return 0;
}
