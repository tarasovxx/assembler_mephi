#include <math.h>
#include <string.h>

void rotate_image_c(void * arg_from, void * arg_to, int w, int h, int new_w, int new_h, int n, double rad){
    unsigned char *src = arg_from, *dst = arg_to;
    int x = 0, y = 0;
    double cosRad = cos(rad);
    double sinRad = sin(rad);

     // Центр нового изображения
    double x0 = new_w / 2.0;
    double y0 = new_h / 2.0;

    // Центр старого изображения
    double xc = w / 2.0;
    double yc = h / 2.0;

    for (y = 0; y < new_h; y++) {
        for (x = 0; x < new_w; x++) {
	    // Перевод координат нового изображения в координаты старого изображения
            double x_rel = x - x0;
            double y_rel = y - y0;

	    int srcX = (int)(cosRad * x_rel - sinRad * y_rel + xc);
            int srcY = (int)(sinRad * x_rel + cosRad * y_rel + yc);

            if (srcX >= 0 && srcX < w && srcY >= 0 && srcY < h) {
                int srcIndex = (srcY * w + srcX) * n; 
                int dstIndex = (y * new_w + x) * n; 

		for (int k = 0; k < n; ++k) {
			dst[dstIndex + k] = src[srcIndex + k];
		}
            } 
	}
    }
}
