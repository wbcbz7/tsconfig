;BLT2 test

    device zxspectrum128
    include "tsconfig.asm"
    
    org   #4000 
start
    di
    ld    sp, #7FFF   
  
    ld    hl, pal
    call  set_ports

    ld    a, #20
    ld    bc, TMPAGE   ; тайлмап - где-нибудь ;)
    out   (c), a
    
    ld    a, #30
    ld    bc, T0GPAGE   ; тайлмап - где-нибудь ;)
    out   (c), a
    
    xor   a
    ld    bc, PALSEL
    out   (c), a
    
    ld    a, VID_256X192 | VID_ZX | VID_NOGFX
    ld    bc, VCONFIG
    out   (c), a
    
    ld    a, TSU_T0EN
    ld    bc, TSCONFIG
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN  ; 14 MHz + cache
    ld    bc,SYSCONFIG 
    out   (c), a    
    
    di
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


pal		db #1a,#00
	        db #1b,#10
		db #1c,5
	        db #1d,0
	        db #1e,0
	        db #1f,0
	        db #26,#FF
	        db #28,0
		db #27,DMA_RAM_CRAM 
		db #ff  
               
c_end               
 
        savebin "tiles.$c", start, (c_end - start)