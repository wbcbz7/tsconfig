#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <math.h>

unsigned char  *screen = 0xA0000;

unsigned char  pal[16*4];
unsigned short tspal[256];

unsigned char  texture[64*64];
unsigned char  buffer[64000];
unsigned short tunnel[128*64];
unsigned char  lightmap[64000];
unsigned char  palxlat[65536];

         short sintab[65536];
         short costab[65536];
         float sintabf[65536];
         
unsigned short sinxlat[65536];

double pi = 3.141592653589793;

#define sat(a, l) ((a > l) ? l : a)

void set160x200() {
    // thanks to type one \\ (tfl-tdv | pulpe(??)) for info about this mode
    // translated to C, should work with S3 cards
    
    // вся жопа в том что нормально этот код на реалах не работает :)

    // method two - set mode 13h and then load horiz.params from mode Dh
    // 100% works on matrox, 70% on S3 (palette corruption)
    // does not work on nvidia and crashes on ati (why?)
    
    //setvidmode(0x13);
    outp (0x3D4, 0x11); outp(0x3D5, (inp(0x3D5) & 0x7F));
    
    outpw(0x3C4, 0x0901); // FUCK YOU S3! :)
    
    // but...they strikes back!
    // unlock S3 extensions
    outpw(0x3C4, 0x0608);
    outpw(0x3D4, 0x4838);
    // and test for presence of S3 card
    outp (0x3D4, 0x30);
    // if S3 detected - use S3 method of VCLK/2
    if (inp(0x3D5) >  0x80) {
        outp(0x3C4, 1);    outp(0x3C5, (inp(0x3C5) & 0xF7));
        outp(0x3C4, 0x15); outp(0x3C5, (inp(0x3C5) | 0x10));
    }
    // lock S3 extensions
    outpw(0x3C4, 0x0008);
    outpw(0x3D4, 0x0038);
    
    outpw(0x3D4, 0x2D00);
    outpw(0x3D4, 0x2701);
    outpw(0x3D4, 0x2802);
    outpw(0x3D4, 0x9003);
    outpw(0x3D4, 0x2B04);
    outpw(0x3D4, 0x8F05);
    
    outpw(0x3D4, 0x1413);
    
    // blacklist (use fake mode):
    // currus logic - out of range DAMNIT!
    // fuckinTrident - DAMN IT LOOKS SOOOOOO ULGY!
    // nvidia - just does not work at all :)

    // короче, 160x100 работает нормально только на матроксе :D
}

void set60hz() {
    // again thanks to type one for info ;)

    outp (0x3D4, 0x11); outp(0x3D5, (inp(0x3D5) & 0x7F)); // unlock registers
    outp (0x3C2, 0xE3);   // misc. output
    outpw(0x3D4, 0x0B06); // vertical total
    outpw(0x3D4, 0x3E07); // overflow
    outpw(0x3D4, 0xC310); // vertical start retrace
    outpw(0x3D4, 0x8C11); // vertical end retrace
    outpw(0x3D4, 0x8F12); // vertical display enable end
    outpw(0x3D4, 0x9015); // vertical blank start
    outpw(0x3D4, 0x0B16); // vertical blank end
}

void buildSinTable() {
    int i, j;
    float r;
    
    for (i = 0; i < 65536; i++) {
        r = (sin(2 * pi * i / 65536));
        sintab[i] = 32767 * r;
        sintabf[i] = r;
        
        r = (cos(2 * pi * i / 65536));
        costab[i] = 32767 * r;
    }
}

void buildTunnel() {
    long rx, x, y, i, u, v, lm;
    double r, a, l;
    
    const TunnelSize = 4096;
    float LightmapScale = 1.1;

    i = 0;
    for (y = -64; y < 64; y++) {
        for (x = -128; x < 128; x++) {
            r = sqrt(x*x + y*y);
            if (r < 1) r = 1;
            a = atan2(y, x) + pi;
            
            u = (a * 128 / pi)  + (sintab[((int)r << 9) & 0xFFFF] >> 10);
            v = r /*+ (sintab[((int)r << 10) & 0xFFFF] >> 12)*/ + (sintab[(u << 9) & 0xFFFF] >> 11);
            
            u >>= 0;
            v >>= 0;
            
            tunnel[i++] = ((u&0x3F) + ((v&0x3F)<<6)) & 0xFFF;
            x++;
        }
    y++;
    }
}
void buildTexture() {
    int x, y, i, k;
    int rx, ry;
    
    /*
    for (y = 0; y < 64; y++) {
        for (x = 0; x < 64; x++) {
            //texture[((y << 8) + x)] = sat((x ^ y), 255) & 0xFF;
            //texture[((y << 8) + x)] = (x ^ y) & 0xFF;
            texture[((y << 6) + x)] = (x ^ y) >> 2;
        }
    }
    */
    
    i = 0;
    for (y = -32; y < 32; y++) {
        for (x = -32; x < 32; x++) {
            //texture[((y << 8) + x)] = sat((x ^ y), 255) & 0xFF;
            //texture[((y << 8) + x)] = (x ^ y) & 0xFF;
            rx = x >> 0; ry = y << 0;
            texture[i++] = sat((int)(0x800 / ((int)abs(x*x * y*y) + 0.00001)), 15) ;
            //texture[i++] = sat((int)(0x300 / (rx*rx + ry*ry + 0.00001)), 15) ;
        }
    }
    
    for (k = 0; k < 1; k++)
    for (i = 0; i < 64*64; i++) 
        texture[i] = (texture[(i-1)&0xFFF] + texture[(i+1)&0xFFF] + 
                      texture[(i-64)&0xFFF] + texture[(i+64)&0xFFF]) >> 2; 
    
}

void drawTunnel (int c) {
    int u1 = (sintab[((c << 7) + (c << 6)) & 0xFFFF] >> 8) + (costab[((c << 4) + (c << 7)) & 0xFFFF] >> 8);
    //int v1 = (c << 1) + (c >> 1);
    int v1 = (c << 1) + (sintab[((c << 8) + (c << 7)) & 0xFFFF] >> 10);
    //int v1 = 0;
    
    int texofs1 = ((v1 << 6) + u1) &0xFFF;
    int i = 0;
    long scrptr = (long)&buffer;
    int k = 0;
    
    
    for (k = 0; k < 128*64; k++)
        //*((char*)scrptr++) = palxlat[(texture[(tunnel[k]+texofs1) & 0xFFFF]) | (lightmap[k] << 8)];
        *((char*)scrptr++) = texture[(tunnel[k]+texofs1) & 0xFFF]; 
}

void dump() {
    FILE *f;
    int x, y, i, c;
    int u, v, texofs;
    //int r, g, b, d;
    
    f = fopen("tunnel.bin", "wb");
    for (i = 0; i < 128*64; i++) {
        tunnel[i] += 0x4000;
    }
    fwrite(&tunnel, sizeof(unsigned short), 128*64, f);
    fclose(f);
    
    f = fopen("texture.bin", "wb");
    for (i = 0; i < 64*64; i++)
        fputc((char)(texture[i] | (texture[i] << 4)), f);
    fclose(f);
    
    c = 0;
    for (i = 0; i < 1140; i++) {
        u = (sintab[((c << 7) + (c << 6)) & 0xFFFF] >> 8) + (costab[((c << 4) + (c << 7)) & 0xFFFF] >> 8);
        v = (c << 1) + (sintab[((c << 8) + (c << 7)) & 0xFFFF] >> 10);
    
        sinxlat[i] = (unsigned short)(((v << 6) + u) & 0xFFF);
        c += 2;
    }
    
    f = fopen("sintab.bin", "wb");
    fwrite(&sinxlat, sizeof(unsigned short), 1140, f);
    fclose(f);
    
    f = fopen("pal.bin", "wb");
    fwrite(&tspal, sizeof(unsigned short), 256, f);
    fclose(f);
}

void initpal() {
    int i, j, k=0;
    int r, g, b;
    unsigned short d;
    
    for (i = 0; i < 16; i++) {
        pal[(i << 2)    ] = sat(((i << 1) + (i << 0) + (i >> 0)), 63);
        pal[(i << 2) + 1] = sat(((i << 1) + (i << 1)), 63); 
        pal[(i << 2) + 2] = sat(((i << 2) + (i << 1)), 63);
    }
    
    for (j = 0; j < 16; j++) {
        for (i = 0; i < 16; i++) {
            r = (((pal[(i << 2)    ] * j) >> 4) + (((63 - pal[(i << 2)    ]) * (16 - j)) >> 4)) >> 1;
            g = (((pal[(i << 2) + 1] * j) >> 4) + (((63 - pal[(i << 2) + 1]) * (16 - j)) >> 4)) >> 1;
            b = (((pal[(i << 2) + 2] * j) >> 4) + (((63 - pal[(i << 2) + 2]) * (16 - j)) >> 4)) >> 1;
        
        /*
            r = (pal[(i << 2)    ] * j) >> 5;
            g = (pal[(i << 2) + 1] * j) >> 5;
            b = (pal[(i << 2) + 2] * j) >> 5;
        */    
            d = ((b) | (g << 5) | (r << 10) | 0x8000); 
            tspal[k++] = d;
        }
    }
}

int main() {
    int i, j, p = 0;
    
    buildSinTable();
    buildTunnel();
    buildTexture();
    
    _asm {
        mov  ax, 13h
        int  10h
    }
    
    initpal();
    set160x200();
    set60hz();
    outp (0x3D4, 9); outp(0x3D5, (inp(0x3D5) & 0x7F) | 3);
    outpw(0x3D4, 0x1013);
    
    for (j = 0; j < 256; j++) for (i = 0; i < 256; i++) palxlat[p++] = (i * j) >> 8;
    
    outp(0x3C8, 0);
    for (i = 0; i < 64; i++) {
        outp(0x3C9, i);
        outp(0x3C9, i); 
        outp(0x3C9, i);
    }
    
    for (i = 0; i < 128*64; i++) {
        *((char*)screen+i) = (char)(tunnel[i] >> 6);
    }
    while (!kbhit()) {} getch();
    
    for (i = 0; i < 128*64; i++) {
        *((char*)screen+i) = (char)(tunnel[i] & 0x3F);
    }
    while (!kbhit()) {} getch();
    
    outp(0x3C8, 0);
    for (i = 0; i < 16; i++) {
        outp(0x3C9, pal[(i << 2)    ]);
        outp(0x3C9, pal[(i << 2) + 1]); 
        outp(0x3C9, pal[(i << 2) + 2]);
    }
    
    outpw(0x3D4, 0x0813);
    memcpy(screen, texture, 4096);
    while (!kbhit()) {} getch();
    outpw(0x3D4, 0x1013);
    
    while (!kbhit()) {
        i++;
        
        while ((inp(0x3DA) & 8) == 8) {}
        while ((inp(0x3DA) & 8) != 8) {}
        //outp(0x3C8, 0); outp(0x3C9, 63); outp(0x3C9, 63); outp(0x3C9, 63); 
        
        memcpy(screen, &buffer, 128*64);
        drawTunnel(i);
        
        //outp(0x3C8, 0); outp(0x3C9, 0);  outp(0x3C9, 0);  outp(0x3C9, 0);
    }
    getch();
    
    _asm {
        mov  ax, 3h
        int  10h
    }
    
    dump();
}
