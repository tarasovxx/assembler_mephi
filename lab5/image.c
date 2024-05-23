#include <math.h>

void rotate_image_c(void * from, void * to, int w, int h, double angle){
    unsigned char *src = from, *dst = to;
    int x, y;
    double rad = angle * (M_PI / 180);

    for (y = 0; y < h; y++) {
        for (x = 0; x < w; x++) {
            int srcX = cos(rad) * (x - w / 2) - sin(rad) * (y - h / 2) + w / 2;
            int srcY = sin(rad) * (x - w / 2) + cos(rad) * (y - h / 2) + h / 2;

            if (srcX >= 0 && srcX < w && srcY >= 0 && srcY < h) {
                int srcIndex = (srcY * w + srcX) * 4; //srcY * w
                int dstIndex = (y * w + x) * 4; // y * w

                dst[dstIndex] = src[srcIndex];
                dst[dstIndex + 1] = src[srcIndex + 1];
                dst[dstIndex + 2] = src[srcIndex + 2];
                dst[dstIndex + 3] = src[srcIndex + 3];
            }
        }
    }
}
