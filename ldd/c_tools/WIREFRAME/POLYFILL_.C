#include <math.h>
#include <strings.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>

typedef struct {
    float x, y, z, col;
} vertex;

typedef struct {
    int a, b, col;
} line;

typedef struct { int x, y; } vertex2d;

#pragma pack (push, 1)
typedef struct {
    unsigned char  page;
    unsigned short offset;
    unsigned char  color;
    unsigned char  length;
    unsigned char  inc;
} postab;
#pragma pack (pop)

#define X_SIZE   256
#define Y_SIZE   192

//#define X_SIZE   320
//#define Y_SIZE   200

#define DIST     90
#define stardist 128
#define spr_size 32
#define lut_size 65536
#define ee       1.0E-6
#define sat(a, l) ((a > l) ? l : a)

#define facenum   12
#define vertexnum 8

double pi = 3.141592653589793;

vertex   p[vertexnum], pt[vertexnum];
vertex2d p2d[vertexnum];

line     f[facenum];

short sintab [lut_size], costab [lut_size];
float sintabf[lut_size], costabf[lut_size];

/*
 -----------------x-
       / | \
    1 /  y  \ 4
     / 2 | 3 \
     
 1 : -inf <= tan(a) <=  -1
 2 :   -1 <= tan(a) <=  0
 3 :    0 <= tan(a) <=  1
 4 :    1 <= tan(a) <=  inf
*/

postab out1[facenum], out2[facenum], out3[facenum], out4[facenum];
int    out1_pos     , out2_pos     , out3_pos     , out4_pos;          

unsigned char spr[spr_size * spr_size];

unsigned char *screen = 0xA0000;
unsigned char buffer[64000];

int random(int a) {
    int i, j; float r;
    
    r = rand();
    r /= RAND_MAX;
    i = a * r;
    return a; // 22:42 �� �����...� �� ���� ��� ����� :)
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
    
    ff = fopen("line.txt", "r");
    for (i = 0; i < facenum; i++) if (!feof(ff)) {
        fscanf(ff, "%i %i %i \n", &a, &b, &col);
        f[i].a = a; f[i].b = b; f[i].col = col;
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
    long scrptr = (long)&buffer;
    long sprptr;
    
    sprptr = (long)&spr;
    px = v->x - (spr_size >> 1); py = v->y - (spr_size >> 1);
        
    if ((py<(Y_SIZE + (spr_size)))&&(py>0)&&(px>0)&&(px<(X_SIZE - (spr_size)))&&(f->z < 0)) {
            
        j = 0;
        scrptr = (long)&buffer + ((py << 8) + (py << 6) + px);
            

        for (y = 0; y < (spr_size); y++) {
            for (x = 0; x < (spr_size); x++) {
                *((char*)scrptr) = sat((*((char*)scrptr) + *((char*)sprptr)), 255);
                scrptr++; sprptr++;
            }
            scrptr += (320 - (spr_size));
        }
    }
}

void linedraw(vertex2d *a, vertex2d *b, line *f) {
    //vertex2d a, b;

    int delta_x, delta_y, dx, dy, t, d;
    int xerr = 0, yerr = 0;
    
    int sx, sy;
    long scrptr;
    
    //a = p2d[f->a]; b = p2d[f->b];
    
    
    // determine dx and dy
    delta_x = b->x - a->x;
    delta_y = b->y - a->y;
    // determine steps by x and y axes (it will be +1 if we move in forward
    // direction and -1 if we move in backward direction
    if (delta_x > 0) dx = 1; else if (delta_x == 0) dx = 0; else dx = -1;
    if (delta_y > 0) dy = 1; else if (delta_y == 0) dy = 0; else dy = -1;
    delta_x = abs(delta_x);
    delta_y = abs(delta_y);
    // select largest from deltas and use it as a main distance
    if (delta_x > delta_y) d = delta_x; else d = delta_y;
    
    sx = a->x; sy = a->y;
    for (t = 0; t <= d + 1; t++)	{	
        scrptr = (long)&buffer + ((sy << 8) + (sy << 6) + sx);
        *((char*)scrptr) = sat((*((char*)scrptr) + f->col), 255);
        //*((char*)scrptr) = f->col;
        // increasing error
        xerr += delta_x;
        yerr += delta_y;
        // if error is too big then we should decrease it by changing
        // coordinates of the next plotting point to make it closer
        // to the true line
        if (xerr > d) {	
            xerr -= d;
            sx += dx;
        }	
        if (yerr > d) {	
            yerr -= d;
            sy += dy;
        }	
    }
}


#define vcode(p) (((p->x < 0) ? 1 : 0) | ((p->x > X_SIZE) ? 2 : 0) | ((p->y < 0) ? 4 : 0) | ((p->y > Y_SIZE) ? 8 : 0))    
 
/* �᫨ ��१�� ab �� ���ᥪ��� ��אַ㣮�쭨� r, �㭪�� �����頥� -1;
   �᫨ ��१�� ab ���ᥪ��� ��אַ㣮�쭨� r, �㭪�� �����頥� 0 � ��ᥪ���
   � ��� ��१��, ����� ��室���� ��� ��אַ㣮�쭨�� */
int lineclip(vertex2d *a, vertex2d *b) {
    int code_a, code_b, code; /* ��� ������� �祪 ��१�� */
    vertex2d *c; /* ���� �� �祪 */
 
    code_a = vcode(a);
    code_b = vcode(b);
 
    /* ���� ���� �� �祪 ��१�� ��� ��אַ㣮�쭨�� */
    while (code_a || code_b) {
        /* �᫨ ��� �窨 � ����� ��஭� ��אַ㣮�쭨��, � ��१�� �� ���ᥪ��� ��אַ㣮�쭨� */
        if (code_a & code_b)
            return -1;
 
        /* �롨ࠥ� ��� c � ���㫥�� ����� */
        if (code_a) {
            code = code_a;
            c = a;
        } else {
            code = code_b;
            c = b;
        }
 
        /* �᫨ c ����� r, � ��।������ c �� ����� x = r->x_min
           �᫨ c �ࠢ�� r, � ��।������ c �� ����� x = r->x_max */
        if (code & 1) {
            c->y += (a->y - b->y) * (0 - c->x) / (a->x - b->x + ee);
            c->x = 0;
        } else if (code & 2) {
            c->y += (a->y - b->y) * (X_SIZE - c->x) / (a->x - b->x + ee);
            c->x = X_SIZE - 1;
        }
        /* �᫨ c ���� r, � ��।������ c �� ����� y = r->y_min
           �᫨ c ��� r, � ��।������ c �� ����� y = r->y_max */
        if (code & 4) {
            c->x += (a->x - b->x) * (0 - c->y) / (a->y - b->y + ee);
            c->y = 0;
        } else if (code & 8) {
            c->x += (a->x - b->x) * (Y_SIZE - c->y) / (a->y - b->y + ee);
            c->y = Y_SIZE - 1;
        }
 
        /* ������塞 ��� */
        if (code == code_a)
            code_a = vcode(a);
        else
            code_b = vcode(b);
    }
 
    /* ��� ���� ࠢ�� 0, ᫥����⥫쭮 ��� �窨 � ��אַ㣮�쭨�� */
    return 0;
}

void FillBuffer() {
    int i, j;
    
    
    for (i = 0; i < 512; i++) {
        j = ((rand() % 31680) << 1) + 320; 
        //buffer[j]   = sat(buffer[j]   + 128, 255);
        //buffer[j-1] = sat(buffer[j-1] + 64, 255);
        //buffer[j+1] = sat(buffer[j+1] + 64, 255);
    }
        
    for (i = 320; i < (64000); i++) {
        //buffer[i] = (buffer[i-1] + buffer[i+1] + buffer[i-320] + buffer[i+320]) >> 2;
        buffer[i] = (buffer[i] >> 1);// + (buffer[i] >> 2) + (buffer[i] >> 3);
        //buffer[i] = (buffer[i] >> 8);
    }
}

void MakeSprite() {
    int x, y, k;
    long sprptr = (long)&spr;
    
    for (y = -(spr_size >> 1); y < (spr_size >> 1); y++) {
        for (x = -(spr_size >> 1); x < (spr_size >> 1); x++) {
            *((char*)sprptr++) = sat((int)(0x600 / ((x*x + y*y) + ee)), 255) & 0xFF;
        }
    }
}

int main() {
    int i, j;

    srand(inp(0x40));
    MakeSinTable();
    MakeSprite();
    
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
    
    inp(0x3da); outp(0x3c0, 0x31); outp(0x3c0, 0xFF);
    
    while (!kbhit()) {} getch();
    
    while (!kbhit()) {
        i++;
        
        while ((inp(0x3DA) & 8) == 8) {}
        while ((inp(0x3DA) & 8) != 8) {}
        //outp(0x3C8, 0); outp(0x3C9, 63); outp(0x3C9, 0); outp(0x3C9, 0); 
        memcpy(screen, buffer, 64000);  
        
        /*
        _asm {
            mov    edi, offset buffer
            mov    eax, 0
            mov    ecx, 16000
            rep    stosd
        }
        */
        FillBuffer();
        //memset(buffer, 0, 64000);

        for (j = 0; j < vertexnum; j++) {
            out1_pos = 0; out2_pos = 0; out3_pos = 0; out4_pos = 0;
            pt[j] = p[j];
            //vecrotate   ((i << 8) & (lut_size-1),
            //             (i << 8) & (lut_size-1),
            //             (i << 8) & (lut_size-1), &pt[j]);
            vecrotate   ((i << 8) & (lut_size-1),
                        ((i << 7) + (int)((lut_size >> 2) * sintabf[(i << 7) & (lut_size - 1)])) & (lut_size - 1),
                        ((i << 6) + (int)((lut_size >> 1) * costabf[(i << 8) & (lut_size - 1)])) & (lut_size - 1),
                        &pt[j]);
            //vecmove     (0,0,0, &pt[j]);
            vecmove     (0,0,-(stardist >> 1), &pt[j]);
            
            //vecmove     (0,0,-(stardist << 0) - (stardist >> 1), &pt[j]);
            vecproject2d(&pt[j], &p2d[j]);
            vecdraw     (&p2d[j], &pt[j]);
        }
        
        for (j = 0; j < facenum; j++) {
            vertex   fa, fb, fd;
            vertex2d ca, cb, cd;
            line cf;
            
            cf = f[j];
            fa = pt[cf.a]; fb = pt[cf.b];
            if ((fb.z > 0) && (fa.z > 0)) continue;
            if (fb.z > fa.z) {fd = fa; fa = fb; fb = fd;}            
            
            if (fa.z > 0){
                //fa.y = fa.y + (fa.y + fb.y) * (-fb.z+DIST) / (fa.z - fb.z);
                //fa.x = fa.x + (fa.x + fb.x) * (-fb.z+DIST) / (fa.z - fb.z);
                //fa.z = -DIST - ee;
                
                fa.y = fa.y + (fa.y + fb.y) * (-fb.z+DIST) / (fa.z - fb.z);
                fa.x = fa.x + (fa.x + fb.x) * (-fb.z+DIST) / (fa.z - fb.z);
                fa.z = -DIST;
            }
            
            vecproject2d(&fa, &ca);
            vecproject2d(&fb, &cb);     
            
            //if (ca.y > cb.y) {cd = cb; cb = ca; ca = cd;} 
            
            if (lineclip(&ca, &cb) == 0) linedraw(&ca, &cb, &cf);
        }
        
        outp(0x3C8, 0); outp(0x3C9, 0); outp(0x3C9, 0); outp(0x3C9, 0);
    }
    getch();

    _asm {
        mov  ax, 3h
        int  10h
    }
}