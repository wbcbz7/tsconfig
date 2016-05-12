; glitchy lens

    device zxspectrum128
    include "tsconfig.asm"

    
;    org   #4000
;    incbin "texture.bin"
;    org   #5000
;    incbin "texture.bin"
;    org   #8000
;    incbin "tunnel.bin"
;    org   #7000
;pal incbin "pal.bin"
    
    org   #6000 
start
    di
    ld hl,pals
    call set_ports
    
    ld    a, 0
    ld    bc,PALSEL
    out   (c),a
   
    ld    a, #40
    ld    bc,VPAGE
    out   (c),a
    ld    bc,PAGE3
    out   (c),a    
    
    ld hl,0		;00 - цвет, заданный в палитре
	ld (#c000),hl
	ld hl,fill_screen
	call set_ports 
    
    ld    a, 32
    ld    bc,GYOFFSL
    out   (c),a 
    
    ld    a,%00000001
    ld    bc,VCONFIG
    out   (c), a
    ld    a,%00000110  ; 14 MHz + cache
    ld    bc,SYSCONFIG 
    out   (c), a    
    
    
    ld    bc, 0
outer
    exx
    ld    a, (VidPage0)
    ld    bc,PAGE3
    out   (c),a
    exx
    ld    sp, #7FFF
    ld    de, #C000

    ld    a, (ScrOfs)
    xor   1
    ld    (ScrOfs), a

    ld    d, a
    exx
    ld    d, a 
    exx
    ld    a, h
    
    ei
    halt
    ld    a, (FrameCounter)
    and   2
;    xor   2
    rra
    exx
    ld    bc, GYOFFSH
    out   (c), a
    exx
    
    di
    ld    sp, #8000
    ex    af, af' ;'
 ;   di
    ld    a, 64
;    ex    af, af'
    ;'
loop    
    ex    af, af' ;'    
    dup 128
    pop   hl
    add   hl, bc
;    ldi
    ld    a, (hl)
    ld    (de), a
    inc   de
;    inc   bc
    edup
    inc   d
    inc   d
    ld    e, 0
    ex    af, af' ;'
    dec   a   
    jp    z, endloop
    nop
    cp    32
    jp    nz, loop
flippage
    ex    af, af' ;'
    ld    a, (VidPage1)
    exx
    ld    bc, PAGE3
    out   (c), a
    ld    a, d
    exx
    ld    d, a
    ex    af, af' ;'
    jp    loop

endloop    ;вылетаем если кадр отрисован
    ex    af, af' ;'    
    ld    hl, (SinTabOfs)
    ld    c, (hl)
    inc   hl
    ld    b, (hl)
    inc   hl
    ld    (SinTabOfs), hl
    
;    ld    a, (FrameCounter)
;    ld    d, a
;    and   2
;    xor   2
;    
;    sla   a
;    or    #40
;    inc   a
;    ld   (VidPage0), a
;    inc   a
;    ld   (VidPage1), a
;    inc   a
;    ld    a, d
;    ld    (FrameCounter), a
    jp    outer
    halt 
    
; зпiзженно у VBI ;)
set_ports	ld c,#AF
.m1		ld b,(hl) 
		inc hl
		inc b
		jr z,dma_stats
		outi
		jr .m1

dma_stats	ld b,high DMASTATUS
		in a,(c)
		AND #80
		jr nz,$-4
		ret   


pals		db #1a,0
	        db #1b,#70
		    db #1c,5
	        db #1d,0
	        db #1e,0
	        db #1f,0
	        db #26,#10
	        db #28,0
		    db #27,DMA_RAM_CRAM     ; #84 - копирование из RAM в CRAM
		    db #ff  
            

fill_screen	defb #1a,0	;
		defb #1b,0	;
		defb #1c,#40	;
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,#40	;

		defb #28,#FF	;
		defb #26,#ff	;
		defb #27,%00000100    ; DMA_FILL
		db #ff    
        
CurGXYOffsH  db 0    
VidPage0     db #41
VidPage1     db #42
ScrOfs       db #C0
FrameCounter db 0

SinTabOfs    dw #7800  

    
    savebin "tunnel.$c", #6000, #1000
;    savesna "tunnel.sna", start