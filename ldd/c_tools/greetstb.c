#include <stdio.h>


int main(){
    int i, j;
    unsigned short k = 0;
    FILE *f;

    f = fopen("greets.bin", "wb");
    for (j = 0; j < 7; j++) {
        fwrite(&k, sizeof(unsigned short), 1, f);
        k++;
    }
    
    k = 64;
    for (j = 0; j < 40; j++) {
        for (i = 0; i < 10; i++) {
            fwrite(&k, sizeof(unsigned short), 1, f);
            k++;
        }      
        k += 6;        
    }
    
    fclose(f);
}
