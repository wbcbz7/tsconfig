#include <math.h>
#include <strings.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>

typedef struct {
    float x, y, z, col;
} vertex;

typedef struct {
    int a, b, c, col;
} face;

typedef struct { int x, y; } vertex2d;

#define X_SIZE   320
#define Y_SIZE   200
#define DIST     300
#define stardist 128
#define lut_size 65536
#define ee       1.0E-6

#define facenum   5
#define vertexnum 4

double pi = 3.141592653589793;

vertex   p[vertexnum], pt[vertexnum];
vertex2d p2d[vertexnum];

face     f[facenum], zf[facenum];

short sintab [lut_size], costab [lut_size];
float sintabf[lut_size], costabf[lut_size];

unsigned char *screen = 0xA0000;
unsigned char buffer[64000];

int random(int a) {
    int i, j; float r;
    
    r = rand();
    r /= RAND_MAX;
    i = a * r;
    return a; // 22:42 на часах...я не хочу еще спать :)
}

void MakeSinTable () {
    int i, j;
    double r, lut_mul;
    lut_mul = (2 * pi / lut_size);
    for (i = 0; i < lut_size; i++) {
        r = i * lut_mul;
        sintab [i] = 32767 * sin(r);
        costab [i] = 32767 * cos(r);
        sintabf[i] = sin(r);
        costabf[i] = cos(r);
    }
}

void vecload() {
    FILE *f;
    int i, j, k;
    float x, y, z;
    
    f = fopen("vertex.txt", "r");
    for (i = 0; i < vertexnum; i++) if (!feof(f)) {
        fscanf(f, "%f %f %f \n", &x, &y, &z);
        p[i].x = x; p[i].y = y; p[i].z = z; p[i].col = 255;
    }
    fclose(f);
}

void triload() {
    FILE *ff;
    int i, j, k;
    int a, b, c, col;
    
    ff = fopen("face.txt", "r");
    for (i = 0; i < facenum; i++) if (!feof(ff)) {
        fscanf(ff, "%i %i %i %i \n", &a, &b, &c, &col);
        f[i].a = a; f[i].b = b; f[i].c = c; f[i].col = col;
    }
    fclose(ff);
}

void vecfill   (vertex *v) {
    v->x = (stardist >> 1) - (rand() % stardist);
    v->y = (stardist >> 1) - (rand() % stardist);
    v->z = (stardist >> 1) - (rand() % stardist);
}

void vecrotate (int ax, int ay, int az, vertex *v) {
    // hehehe, this code is fully ported from my old freebasic demoz ;)
    int i;
    float sinx = sintabf[ax], cosx = costabf[ax];
    float siny = sintabf[ay], cosy = costabf[ay];
    float sinz = sintabf[az], cosz = costabf[az];
    float bx, by, bz, px, py, pz;  // temp var storage

        
    py = v->y;
    pz = v->z;
    v->y = (py * cosx - pz * sinx);
    v->z = (py * sinx + pz * cosx);
        
    px = v->x;
    pz = v->z;
    v->x = (px * cosy - pz * siny);
    v->z = (px * siny + pz * cosy);
        
    px = v->x;
    py = v->y;
    v->x = (px * cosz - py * sinz);
    v->y = (px * sinz + py * cosz);

} 

void vecmove (float ax, float ay, float az, vertex *v) {
    
    v->x += ax;
    v->y += ay;
    v->z += az;
}

void vecproject2d (vertex *v, vertex2d *f) {
    float t;
    
    if (v->z < 0) {
        t = DIST / (v->z + ee);
        f->x = (v->x * t) + (X_SIZE >> 1);
        f->y = (v->y * t) + (Y_SIZE >> 1);
    } 
}

void vecdraw (vertex2d *v, vertex *f) {
    int i, y, x, j;
    int px, py, ofs;
    long scrptr;
    
    if ((v->y < Y_SIZE) && (v->y > 0) && (v->x > 0) && (v->y < X_SIZE) && (f->z < 0)) {
        scrptr = (long)&buffer + ((v->y << 8) + (v->y << 6) + v->x);
        *((char*)scrptr) = f->col;
    }
}

void polydraw(face *f) {
    vertex2d a, b, c, d;
    int fa, fb, fc;
    int sx1, sx2, sx3, dx1, dx2, sy;
    int k_ab, k_bc, k_ac;
    int i;
    long scrptr;
    
    a = p2d[f->a]; b = p2d[f->b]; c = p2d[f->c];
    
    /*
    If a.y > b.y Then Swap a, b
	If a.y > c.y Then Swap a, c
	If b.y > c.y Then Swap b, c
    */
    
    
    if (a.y >= b.y) {d = a; a = b; b = d;}
    if (a.y >= c.y) {d = a; a = c; c = d;}
    if (b.y >= c.y) {d = b; b = c; c = d;}
    
    
    if (b.y == c.y) {k_bc = 0;} else {k_bc = (((c.x - b.x) << 16)) / (c.y - b.y);}
    
    if (a.y == c.y) {return;  } else {k_ac = (((c.x - a.x) << 16)) / (c.y - a.y);}
    
    if (b.y == a.y) {k_ab = 0;} else {k_ab = (((b.x - a.x) << 16)) / (b.y - a.y);}
    
    dx1 = a.x << 16; dx2 = dx1;
    
    if (a.y != b.y) for (sy = a.y; sy < b.y; sy++) {
        sx1 = (dx1 >> 16); sx2 = (dx2 >> 16);
        
        if (sx1 > sx2) {sx3 = sx1; sx1 = sx2; sx2 = sx3;}
        scrptr = (long)&buffer + ((sy << 8) + (sy << 6) + sx1);
        
        for (i = sx1; i < sx2; i++) *((char*)scrptr++) = f->col;
        dx1 += k_ac; dx2 += k_ab;
    }
    
    if (b.y == c.y) {return;}
    for (sy = b.y; sy < c.y; sy++) {
        sx1 = (dx1 >> 16); sx2 = (dx2 >> 16);
        
        if (sx1 > sx2) {sx3 = sx1; sx1 = sx2; sx2 = sx3;}
        scrptr = (long)&buffer + ((sy << 8) + (sy << 6) + sx1);
        
        for (i = sx1; i < sx2; i++) *((char*)scrptr++) = f->col;
        dx1 += k_ac; dx2 += k_bc;
    }
}

int main() {
    int i, j;

    srand(inp(0x40));
    MakeSinTable();
    
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
        outp(0x3C9, (i >> 2) + (i >> 8));
        outp(0x3C9, (i >> 2) + (i >> 8)); 
        outp(0x3C9, (i >> 2) + (i >> 8));
    }
    
    /*
    p[0].x = 0  ; p[0].y = 64; p[0].z = 0; p[0].col = 64;
    p[1].x = -32; p[1].y = -32;  p[1].z = 0; p[1].col = 128;
    p[2].x = 32 ; p[2].y = -32;  p[2].z = 0; p[2].col = 192;
    */
    
    vecload();
    triload();
    
    /*
    for (j = 0; j < vertexnum; j++) {
        vecfill(&p[j]);
        p[j].col = (j + 1) * (255 / vertexnum);
    }
    */
    
    while (!kbhit()) {
        i++;
        
        while ((inp(0x3DA) & 8) == 8) {}
        while ((inp(0x3DA) & 8) != 8) {}
        outp(0x3C8, 0); outp(0x3C9, 63);   
        memcpy(screen, buffer, 64000);  
        
        _asm {
            mov    edi, offset buffer
            mov    eax, 0
            mov    ecx, 16000
            rep    stosd
        }
        
        //memset(buffer, 0, 64000);

        for (j = 0; j < vertexnum; j++) {
            pt[j] = p[j];
            vecrotate   ((i << 4) & (lut_size-1), (i << 4) & (lut_size-1), (i << 4) & (lut_size-1), &pt[j]);
            vecmove     (0,0,(sintab[(i << 8) & (lut_size - 1)] >> 10) - DIST, &pt[j]);
            vecproject2d(&pt[j], &p2d[j]);
            vecdraw     (&p2d[j], &pt[j]);
        }
        
        for (j = 0; j < facenum; j++) {
            polydraw(&f[j]);
        }
        
        outp(0x3C8, 0); outp(0x3C9, 0);
    }
    getch();

    _asm {
        mov  ax, 3h
        int  10h
    }
}