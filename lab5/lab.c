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
	long png = 0x0a1a0a0d474e5089;
	char buf[8];
	FILE * f;
	struct timespec t, t1, t2;
	void * imgfrom, * imgto;
	int w, h, n;

	if (argc != 4) {
		fprintf(stderr, "Usage: %s png_file c_result asm_result\n", argv[0]);
		return 1;
	}

	if ((f=fopen(argv[1], "r")) == NULL) {
		perror(argv[1]);
		return 1;
	}

	fread(buf, 1, sizeof(long), f);
	fclose(f);
	n =4;

	if (*(long *)buf != png){
		fprintf(stderr, "%s - not correct signature png_file\n", argv[1]);
		return 1;
	}

	if ((imgfrom=stbi_load(argv[1], &w, &h, &n, 4)) == NULL){
		fprintf(stderr, "%s - not correct png_file\n", argv[1]);
		return 1;
	}
	n = 4;

	printf("Image loads: %d * %d pixels, %d channels\n", w, h, n);
	int angle;
	printf("PLease write angle:");
	scanf("%d", &angle);
	if (angle < 0 || angle >= 360) {
 		fprintf(stderr, "Angle must be between 0 and 359\n");
        	//stbi_image_free(imgfrom);
		free(imgfrom);
        	return 1;
    	}

	double rad = fabs(angle * (M_PI / 180));
	double diagonal = sqrt(w * w + h * h);
	int new_w = ceil(diagonal);
	int new_h = ceil(diagonal);

	if ((imgto=calloc(new_w * new_h * n, 1))==NULL){
		fprintf(stderr, "Can't allocate memory for image\n");
		free(imgfrom);
		return 1;
	}

	printf("new_w: %d\nnew:h: %d\n", new_w, new_h);

	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
	rotate_image_c(imgfrom, imgto, w, h, new_w, new_h, n, rad);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
	t.tv_sec=t2.tv_sec-t1.tv_sec;
	if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
		t.tv_sec--;
		t.tv_nsec+=1000000000;
	}
	printf("C: %ld.%09ld\n", t.tv_sec, t.tv_nsec);
	if (stbi_write_png(argv[2], new_w, new_h, n, imgto, new_w * n)==0)
		printf("Cannot write image_c to file\n");

	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
	printf("x: %d\ny: %d\n", new_w, new_h);
	work_image_asm(imgfrom, imgto, w, h, rad);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
	t.tv_sec=t2.tv_sec-t1.tv_sec;

	if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
		t.tv_sec--;
		t.tv_nsec+=1000000000;
	}

	printf("Asm: %ld.%09ld\n", t.tv_sec, t.tv_nsec);
	if (stbi_write_png(argv[3], new_w, new_h, n, imgto, new_w * n)==0)
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
