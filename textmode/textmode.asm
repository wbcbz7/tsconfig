;do not run under wild commander!

    device zxspectrum128
    include "tsconfig.asm"
    
    org   #4000 
start
    di
    ld    sp, #7FFF   
   
    ld    a, #40
    ld    bc, VPAGE
    out   (c),a
    ld    b, high PAGE3
    out   (c),a     
    
    ld    a, #0
    ld    b, high GYOFFSL
    out   (c),a
    ld    b, high GYOFFSH
    out   (c),a
    ld    b, high GXOFFSL
    out   (c),a
    ld    b, high GXOFFSH
    out   (c),a
    
    ld    hl,#0707		;00 - цвет, заданный в палитре
    ld    (#C000),hl
    ld    hl,fill_screen
    call  set_ports  

    ld    hl,copy_text
    call  set_ports     
    
    ld    a, VID_320X200 | VID_TEXT
    ld    b, high VCONFIG
    out   (c), a
    
    ld    a, #F0
    ld    b, high BORDER
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN  ; 14 MHz + cache
    ld    b, high SYSCONFIG 
    out   (c), a    
    
    ld    hl, 0 
loop
    inc   hl
    ei
    halt
    ld    a, h
    ld    b, high GYOFFSH
    out   (c), a
    
    ld    a, l
    ld    b, high GYOFFSL
    out   (c), a
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


;pal		db #1a,#00
;	        db #1b,#10
;		db #1c,2
;	        db #1d,0
;	        db #1e,0
;	        db #1f,0
;	        db #26,#FF
;	        db #28,0
;		db #27,DMA_RAM_CRAM 
;		db #ff  
            

fill_screen	db #1a,0	;
		db #1b,0	;
		db #1c,#40	;
		db #1d,0	;
		db #1e,0	;
		db #1f,#40	;

		db #28,#1F	;
		db #26,#FF	;
		db #27,DMA_FILL | DMA_DALGN
		db #ff
                
copy_text       db #1a,0	;
                db #1b,0	;
                db #1c,#50	;
                db #1d,0	;
                db #1e,0	;
                db #1f,#40	;

                db #28,#3	;
                db #26,#7F	;
                db #27,DMA_RAM | DMA_DALGN
                db #ff
;                

               
c_end               
 
        savebin "textmode.$c", start, (c_end - start)