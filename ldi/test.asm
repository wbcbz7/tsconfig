    device zxspectrum128
    include "tsconfig.asm"
     
    org   #8000 
start  
    ld    a, #20
    ld    bc,VPAGE
    out   (c),a
    inc   a
    ld    bc,PAGE3
    out   (c),a
    ld    a,%00000001
    ld    bc,VCONFIG
    out   (c),a
    LD  HL,#C000      
           LD  DE,#C001
           LD  BC,#3fff
           XOR  A
           LD  (HL),A
           LDIR
    
    
loop    
    ld    b, #FF
    xor   a
inner    
    push  bc
    ld    bc, GYOFFSL
    out   (c), a
    inc   a
    pop   bc
    ei
    halt
    djnz  inner
    jp    loop
    
    savesna "test.sna", start
    
    