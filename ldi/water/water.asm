
    device zxspectrum128
    include "tsconfig.asm"
    
    org   #4000 
start
    di
    ld    sp, #7FFF   
  
    ld    hl, pal
    call  set_ports

    ld    a, #20
    ld    bc, TMPAGE   
    out   (c), a

    ld    b, high PAGE3   
    out   (c), a
    
    ld    hl, #1000
    ld    (#C000), hl
    ld    hl, clr_tmap
    call  set_ports
    
    ld    a, #30
    ld    b, high T0GPAGE 
    out   (c), a
    
    ld    a, 8
    ld    b, high T0XOFFSL
    out   (c), a
    
    ld    a, #10
    ld    b, high BORDER
    out   (c), a
    
    xor   a
    ld    b, high PALSEL
    out   (c), a
    
    ld    a, VID_320X240 | VID_ZX | VID_NOGFX
    ld    b, high VCONFIG
    out   (c), a
    
    ld    a, TSU_T0EN
    ld    b, high TSCONFIG
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN  ; 14 MHz + cache
    ld    b, high SYSCONFIG 
    out   (c), a    
    
    ; ПОЕХАЛИИИИИИИИИИИИИИИ!!!!! :)

    ld    bc, 0
    ei                      ; можно не бояться, что нас выкинут в космос :)
frame
    halt
    
    ld    hl, bc
    ld    a, (buf2)
    and   #20
    rlca
    rlca
    rlca
    ld    bc, T0YOFFSH
    out   (c), a
    ld    bc, hl
    
    ld    a, b
    cp    1
    jr    z, skip
    call  put_rnd
skip
    exx
    ld    e, 2
    ld    a, (buf1)
    ld    d, a
    inc   d
    ld    bc, #271F         ; B - x counter, C - y counter (40 x 30)
    
    jp    y_loop
    align 512
;-----------------------------vvv    
y_loop   
;----------------vvv
x_loop    
    ld    hl, de
    dec   h
    dec   l
    dec   l
    ld    a, (hl)
    inc   l
    inc   l
    add   a, (hl)
    inc   l
    inc   l
    add   a, (hl)
    inc   h
    add   a, (hl)
    dec   l
    dec   l
    dec   l
    dec   l
    add   a, (hl)
    inc   h
    add   a, (hl)
    inc   l
    inc   l
    add   a, (hl)
    inc   l
    inc   l
    add   a, (hl)
    
    push  af
    
    ld    a, d
    and   #1F
    ld    h, a
    ld    a, (buf2)
    add   h
    ld    h, a
    ld    l, e
    
    pop   af
    
    sub   a, (hl)
    sub   a, (hl)
    sub   a, (hl)
    sub   a, (hl)
    
    sra   a
    sra   a
    
    push  de
;    ld    d, a
;    sra   d
;    sub   a, d
    ld    (hl), a
    pop   de
    
    inc   e                 
    inc   e                 
    
    djnz  x_loop    
;----------------^^^
    inc   d
    ld    e, 2    
    dec   c
    ld    b, #27
    jr    nz, y_loop
;-----------------------------^^^    

tmp_ db 0
    
; CALC_WATER (SOURCE, DEST)

; for y = 1 to height-2
;  for x = 1 to width-2
;
;      pixel = (source[x,   y+1]
;             + source[x,   y-1]
;             + source[x+1, y]
;             + source[x-1, y]
;             + source[x-1, y-1]
;             + source[x+1, y-1]
;             + source[x-1, y+1]
;             + source[x+1, y+1]
;
;             - dest[x,y] << 2 ) >> 2
;
;   dest[x,y] =  pixel  - (pixel >> density)
;   
;  next x
; next y

    exx
    ld    a, (buf1)
    ld    (tmp), a
    ld    a, (buf2)
    ld    (buf1), a
    ld    a, (tmp)
    ld    (buf2), a
    
    inc   bc
    jp    frame
    
put_rnd                   ; put random "drop" 
    call FastGalois16
    and  #3F
    inc  a
    rlca
    ld   e, a
    
    call FastGalois16
    and  #1F
    or   #C0
    ld   d, a
    
    ld   a, 15
    ld   (de), a 
    dec  d
    ld   (de), a
    inc  d
    inc  d
    ld   (de), a
    dec  d
    inc  e
    inc  e
    ld   (de), a
    dec  e
    dec  e
    dec  e
    dec  e
    ld   (de), a
    ret
   
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
               
clr_tmap	db #1a,0
	        db #1b,0
		db #1c,#20
	        db #1d,0
	        db #1e,0
	        db #1f,#20
	        db #26,#FF
	        db #28,#1F
		db #27,DMA_FILL
		db #ff 

; hi, spke! ;)
FastGalois16
        db    #21        ; ld hl, nn
        ;ld   hl, #FFFF  ; 10
SeedValue
        dw    #FFFF
        ;EQU   $-2
        add   hl, hl    ; 11
        sbc   a         ; 4
        and   #BD       ; 7   instead of #BD, one can use #3F or #D7
        xor   l         ; 4
        ld    l, a      ; 4
        ld    (SeedValue), hl      ; 16
        ; =================================
        ld    a, h
        and   %10101010
        add   l         ; +4+7+4 => +15t overhead
        ; =================================
        ret             ; 10 => 10+11+4+7+4+4+16 + 10 = 66t
 
buf1    db    #C0
buf2    db    #E0
tmp     db    0
 
c_end               
 
        savebin "water.$c", start, (c_end - start)