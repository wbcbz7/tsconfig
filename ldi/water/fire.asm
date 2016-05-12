
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
    
    ld    hl, #0000
    ld    (#C000), hl
    ld    hl, clr_tmap
    call  set_ports
    
    ld    a, #30
    ld    b, high T0GPAGE 
    out   (c), a
    
    ld    a, 8
    ld    b, high T0XOFFSL
    out   (c), a
    
;    ld    a, #10
;    ld    b, high BORDER
;    out   (c), a
    
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
    ld    a, b
    cp    1
    jr    z, skip
    dup   8                 ; кол-во огоньков за фрейм
    call  put_rnd
    edup
    call  put_rnd_any
skip
    exx
    ld    de, #C000
    ld    bc, #2C20         ; B - x counter, C - y counter (32 x 24)
    jp    y_loop
    align 512
;-----------------------------vvv    
y_loop    
;----------------vvv
; конфигурация фильтра:
;     0 0 0
;     0 1 0
;     1 1 1
    ld    h, d
x_loop    

    ld    l, e              ; 4
    ld    a,(hl)            ; 7
    inc   h                 ; 4
    dec   l                 ; 4
    dec   l                 ; 4
    add   a,(hl)            ; 7
    inc   l                 ; 4
    inc   l                 ; 4
    add   a,(hl)            ; 7
    inc   l                 ; 4
    inc   l                 ; 4
    add   a,(hl)            ; 7
    rra                     ; 4
    rra                     ; 4
    and   #0F               ; 7
    
    ld    (de), a           ; 7  
    inc   e                 ; 4
    inc   e                 ; 4
    dec   h                 ; 4

    djnz  x_loop            ; 13 
;----------------^^^        total = 107 t-states *FACEPALM*
    inc   d
    ld    e, 0    
    dec   c
    ld    b, #2C
    jr    nz, y_loop
;-----------------------------^^^    
    exx
    inc   bc
    jp    frame

put_rnd                    ; put random "flare" on bottom line
    ld   d, #DE            ; bottom line
    call FastGalois16
    and  #3F
    inc  a
    rlca
    ld   e, a
    ld   a, 15
    ld   (de), a 
    inc  e
    inc  e
    ;dec  a
    ld   (de), a
    dec  e
    dec  e
    dec  e
    dec  e
    ;dec  a
    ld   (de), a
    dec  d
    dec  a
    ld   (de), a
    ret
    
put_rnd_any                ; put random "flare" on bottom line
    call FastGalois16
    and  #3F
    inc  a
    rlca
    ld   e, a
    
    call FastGalois16
    and  #0F
    or   #D0
    ld   d, a
    
    ld   a, 15
    ld   (de), a 
    inc  e
    inc  e
    ;dec  a
    ld   (de), a
    dec  e
    dec  e
    dec  e
    dec  e
    ;dec  a
    ld   (de), a
    dec  d
    dec  a
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
        
c_end               
 
        savebin "fire.$c", start, (c_end - start)