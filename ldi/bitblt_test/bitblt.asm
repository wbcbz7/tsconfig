;BLT2 test

    device zxspectrum128
    include "tsconfig.asm"
    
    org   #4000 
start
    di
    ld    sp, #7FFF   
  
    ld    hl, pal
    call  set_ports
   
    ld    a, #40
    ld    bc,VPAGE
    out   (c),a
    ld    bc,PAGE3
    out   (c),a    
    
    ld    hl,#0		;00 - цвет, заданный в палитре
    ld    (#C000),hl
    ld    hl,fill_screen
    call  set_ports     

    ld    a, #80
    ld    bc, BORDER
    out   (c), a
    
    ld    a, VID_256X192 | VID_256C
    ld    bc, VCONFIG
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN  ; 14 MHz + cache
    ld    bc,SYSCONFIG 
    out   (c), a    
    
    ld    d, 0 
loop
    inc   d
    ld    a, d
    ld    (spr_ofs), a
    ld    hl, sprite
    call  set_ports
    ei
    halt
    jr    loop    
   

   
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


pal		db #1a,#00
	        db #1b,#10
		db #1c,2
	        db #1d,0
	        db #1e,0
	        db #1f,0
	        db #26,#FF
	        db #28,0
		db #27,DMA_RAM_CRAM 
		db #ff  
            

fill_screen	db #1a,0	;
		db #1b,0	;
		db #1c,#40	;
		db #1d,0	;
		db #1e,0	;
		db #1f,#40	;

		db #28,#FF	;
		db #26,#FF	;
		db #27,DMA_FILL
		db #ff
                
sprite          db #1a,0	;
		db #1b,0	;
		db #1c,2	;
		db #1d
spr_ofs         db 0
		db #1e,0	
		db #1f,#40	;

		db #28,63	;
		db #26,31	;
		db #27,DMA_BLT2 | DMA_DALGN | DMA_ASZ | #40
		db #ff
               
c_end               
 
        savebin "bitblt.$c", start, (c_end - start)