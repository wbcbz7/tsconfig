#include <math.h>
#include <strings.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>

#include "rtctimer.h"

typedef struct {
    float x, y, z, d;
} vertex;

typedef struct { float x, y; } vertex2d;

#pragma pack (push, 1)
typedef struct {
    unsigned char  page;
    unsigned short offset;
} postab;
#pragma pack (pop)

//#define X_SIZE 256
//#define Y_SIZE 192

#define X_SIZE 320
#define Y_SIZE 200
#define DIST   300

#define stardist 72
#define count    64
#define lut_size 65536
#define spr_size 16
#define sat(a, l) ((a > l) ? l : a)
#define ee        1.0E-6

int random(int a) {
    int i, j; float r;
    
    r = rand();
    r /= RAND_MAX;
    i = a * r;
    return a; // 22:42 на часах...я не хочу еще спать :)
}

double pi = 3.141592653589793;

unsigned char spr[spr_size * spr_size];

vertex   p[count], pt[count], pm[count];
vertex2d p2d[count];

postab   outbuf[count+1];

short sintab[lut_size];
float sintabf[lut_size], costabf[lut_size];

unsigned char  *screen = 0xA0000;
unsigned char fxbuffer[64320];
unsigned char fxrnd[64000];

void fxMakeSinTable () {
    int i, j;
    double r, lut_mul;
    lut_mul = (2 * pi / lut_size);
    for (i = 0; i < lut_size; i++) {
        r = i * lut_mul;
        sintab[i] = 32767 * sin(r);
        sintabf[i] = sin(r);
        costabf[i] = cos(r);
    }
}

void fxInitRnd() {
    int i, j;
    for (i = 0; i < 64000; i++) {
        fxrnd[i] = (rand() & 0xFF);
    }
}

void fx3dRotate (int ax, int ay, int az) {
    // hehehe, this code is fully ported from my old freebasic demoz ;)
    int i;
    float sinx = sintabf[ax], cosx = costabf[ax];
    float siny = sintabf[ay], cosy = costabf[ay];
    float sinz = sintabf[az], cosz = costabf[az];
    float bx, by, bz, px, py, pz;  // temp var storage
    for (i = 0; i < count; i++) {
        pt[i] = pm[i];
        
        py = pt[i].y;
        pz = pt[i].z;
        pt[i].y = (py * cosx - pz * sinx);
        pt[i].z = (py * sinx + pz * cosx);
        
        px = pt[i].x;
        pz = pt[i].z;
        pt[i].x = (px * cosy - pz * siny);
        pt[i].z = (px * siny + pz * cosy);
        
        px = pt[i].x;
        py = pt[i].y;
        pt[i].x = (px * cosz - py * sinz);
        pt[i].y = (px * sinz + py * cosz);
    }
} 

void fx3dMove (float ax, float ay, float az) {
    int i;
    
    for (i = 0; i < count; i++) {
        pt[i].x += ax;
        pt[i].y += ay;
        pt[i].z += az;
    }
}

void fx3dMovep (float ax, float ay, float az) {
    int i;
    
    for (i = 0; i < count; i++) {
        pm[i].x = p[i].x + ax;
        pm[i].y = p[i].y + ay;
        pm[i].z = p[i].z + az;
    }
}

void fx3dProject () {
    int i;
    float t;
    for (i = 0; i < count; i++) if (pt[i].z < 0) {
        t = DIST / (pt[i].z + ee);
        p2d[i].x = pt[i].x * t + (X_SIZE >> 1);
        p2d[i].y = pt[i].y * t + (Y_SIZE >> 1);
    }
}

void fxDrawPoints () {
    int i, y, x, j;
    int px, py, ofs;
    long scrptr = (long)&fxbuffer;
    long sprptr = (long)&spr;
    
    for (i = 0; i < count; i++) {
        sprptr = (long)&spr;
        px = p2d[i].x - (spr_size >> 1); py = p2d[i].y - (spr_size >> 1);
        
        if ((py<(Y_SIZE + (spr_size)))&&(py>0)&&(px>0)&&(px<(X_SIZE - (spr_size)))&&(pt[i].z < 0)) {
            
            j = 0;
            scrptr = (long)&fxbuffer + ((py << 8) + (py << 6) + px);
            
            /*
            *((char*)scrptr) = sat((*((char*)scrptr) + 64), 255);
            *((char*)scrptr+1) = sat((*((char*)scrptr+1) + 32), 255);
            *((char*)scrptr-1) = sat((*((char*)scrptr-1) + 32), 255);
            */
            for (y = 0; y < (spr_size); y++) {
                for (x = 0; x < (spr_size); x++) {
                    *((char*)scrptr) = sat((*((char*)scrptr) + *((char*)sprptr)), 255);
                    //*((char*)scrptr) = (*((char*)scrptr) + *((char*)sprptr));
                    scrptr++; sprptr++;
                }
                scrptr += (320 - (spr_size));
            }
        }
    }
}

#define sd stardist

void fxFillDots (int c) {
    int rat, max, phi, teta, count2, i, lptr = 0;
    
    max = sqrt(count);
    rat = lut_size / max;
    
    for (teta = 0; teta < max; teta++)
        for (phi = 0; phi < max; phi++) {
        p[lptr  ].x = (stardist + 32 * sintabf[((c << 10) - (teta << 12)) & (lut_size - 1)]) * sintabf[((phi*rat) + (int)((lut_size << 1) * sintabf[(c << 6) & (lut_size-1)])) & (lut_size-1)];
        p[lptr  ].y = (stardist + 32 * sintabf[((c << 10) - (teta << 12)) & (lut_size - 1)]) * costabf[((phi*rat) + (int)((lut_size << 1) * sintabf[(c << 6) & (lut_size-1)])) & (lut_size-1)];
        p[lptr++].z = ((sd >> 1) * max ) - (sd >> 0) * teta ;
    }
    /*
    for (teta = 0; teta < max; teta++)
        for (phi = 0; phi < max; phi++) {
        p[lptr  ].x = ((stardist<<1) + (stardist * fxcostabf[phi*rat]))*fxcostabf[teta*rat];
   		p[lptr  ].y = ((stardist<<1) + (stardist * fxcostabf[phi*rat]))*fxsintabf[teta*rat];
	    p[lptr++].z = stardist * fxsintabf[phi*rat];
    }
    */
        
}

void fxFillBuffer() {
    int i, j;
    
    
    for (i = 0; i < 512; i++) {
        j = ((rand() % 31680) << 1) + 320; 
        fxbuffer[j]   = sat(fxbuffer[j]   + 128, 255);
        fxbuffer[j-1] = sat(fxbuffer[j-1] + 64, 255);
        fxbuffer[j+1] = sat(fxbuffer[j+1] + 64, 255);
    }
        
    for (i = 320; i < (64000); i++) {
        //fxbuffer[i] = (fxbuffer[i-1] + fxbuffer[i+1] + fxbuffer[i-320] + fxbuffer[i+320]) >> 2;
        fxbuffer[i] = (fxbuffer[i] >> 1) + (fxbuffer[i] >> 2);// + (fxbuffer[i] >> 3);
        //fxbuffer[i] = (fxbuffer[i] >> 8);
    }
}

void fxMakeSprite() {
    int x, y, k;
    long sprptr = (long)&spr;
    
    for (y = -(spr_size >> 1); y < (spr_size >> 1); y++) {
        for (x = -(spr_size >> 1); x < (spr_size >> 1); x++) {
            *((char*)sprptr++) = sat((int)(0x200 / ((x*x + y*y) + ee)), 192) & 0xFF;
        }
    }
}

FILE *f;
void dump() {
    int i, j, x, y, px, py;
    
    j = 0;
    for (i = 0; i < count; i++) {
        px = p2d[i].x - (spr_size >> 1); py = p2d[i].y - (spr_size >> 1);
        if ((py<(Y_SIZE + (spr_size)))&&(py>0)&&(px>0)&&(px<(X_SIZE - (spr_size)))&&(pt[i].z < 0)) {
            outbuf[j].offset = ((py & 31) << 9) | (px & 510);
            outbuf[j].page   = ((py & (255-31)) >> 5) | 0x40;
            j++;
        }
    }
    fwrite(&outbuf, sizeof(postab), j, f);
    fputc(0xFF, f);
}

void sprdump() {
    FILE *ff;
    
    ff = fopen("sprite.bin", "wb");
    fwrite(&spr, sizeof(unsigned char), sizeof(spr), ff);
    fclose(ff);
}

int fxtick=0;

void fxTimer() { fxtick++; }

int main () {
    int i;

    fxMakeSinTable();
    f = fopen("pos.bin", "wb");
    
    _asm {
        mov  ax, 13h
        int  10h
        
        // zpizzheno ;)
        mov ax,13h
        int 10h       // regular mode 13h chained

        mov dx,3d4h   // remove protection
        mov al,11h
        out dx,al
        inc dl
        in  al,dx
        and al,7fh
        out dx,al

        mov dx,3c2h   // misc output
        mov al,0e3h   // clock
        out dx,al

        mov dx,3d4h
        mov ax,00B06h // Vertical Total
        out dx,ax
        mov ax,03E07h // Overflow
        out dx,ax
        mov ax,0C310h // Vertical start retrace
        out dx,ax
        mov ax,08C11h // Vertical end retrace
        out dx,ax
        mov ax,08F12h // Vertical display enable end
        out dx,ax
        mov ax,09015h // Vertical blank start
        out dx,ax
        mov ax,00B16h // Vertical blank end
        out dx,ax 
              
    }

    outp(0x3C8, 0);
    for (i = 0; i < 256; i++) {
        outp(0x3C9, (i >> 3) + (i >> 4));
        outp(0x3C9, (i >> 2) - (i >> 5)); 
        outp(0x3C9, (i >> 3) + (i >> 4));
    }
    
    fxMakeSprite();
    fxInitRnd();
    
    while (!kbhit()) {} getch();
    
    rtc_initTimer(4);
    rtc_setTimer(&fxTimer, rtc_timerRate / 60);
    
    //while (!kbhit()) {
    while (i < 1024) {
        //i = fxtick;
        i++;
        
        fxFillDots(i);
        
        while ((inp(0x3DA) & 8) == 8) {}
        while ((inp(0x3DA) & 8) != 8) {}
        //outp(0x3C8, 0); outp(0x3C9, 16); outp(0x3C9, 16);  outp(0x3C9, 16);   
        memcpy(screen, fxbuffer, 64000);  
        fxFillBuffer();

        fx3dMovep(0 * costabf[(i << 8) & (lut_size - 1)], 0 * costabf[(i << 8) & (lut_size - 1)], 0);
        
        //fx3dRotate((i << 9) & (lut_size - 1),lut_size >> 2,0);
        //fx3dRotate((i << 9) & (lut_size - 1),lut_size >> 2,lut_size >> 2);
        
        //fx3dMovep(0,
        //         (stardist<<1) * fxsintabf[(i << 9) & (lut_size - 1)],
        //         (stardist<<1) * fxcostabf[(i << 9) & (lut_size - 1)]);
        
        //fx3dRotate(4096 * fxcostabf[(i << 8) & (lut_size - 1)] + (lut_size >> 1),
        //           4096 * fxsintabf[(i << 8) & (lut_size - 1)] + (lut_size >> 1),
        //           0);
        
        
        fx3dRotate(0,
                   4096 * costabf[(i << 8) & (lut_size - 1)] + (lut_size >> 1),
                   (lut_size >> 2));
                   
        //fx3dRotate(0,
        //           0,
        //           0);
        
        //fx3dRotate(((i << 6) + (i << 7)) & (lut_size-1),
        //           ((i << 5) + (i << 8)) & (lut_size-1),
        //           0);
        
        //outp(0x3C8, 0); outp(0x3C9, 16); outp(0x3C9, 16); outp(0x3C9, 0);
        
        //fx3dMove  (0,0,(stardist<<1) * costabf[(i << 9) & (lut_size - 1)] - (stardist << 1));
        fx3dMove  (0,64 * costabf[(i << 9) & (lut_size - 1)], -192);
        
        fx3dProject();
        //memset(fxbuffer, 0, 64000);
        //outp(0x3C8, 0); outp(0x3C9, 16); outp(0x3C9, 0); outp(0x3C9, 0);
        fxDrawPoints();

        dump();
        
        outp(0x3C8, 0); outp(0x3C9, 0); outp(0x3C9, 0); outp(0x3C9, 0);
    }
    getch();
    sprdump();
    rtc_freeTimer();
    fclose(f);
}