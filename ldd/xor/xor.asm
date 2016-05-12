
    device zxspectrum128
    include "tsconfig.asm"
    
    org   #4000 
start
    di
    ld    sp, #7FFF   
  
    ld    hl, int_handler
    ld    (#6EFF), hl
    
    ld    a, #6E
    ld    i, a
    
    ld    bc, INTMASK
    ld    a, INT_MSK_FRAME
    out   (c), a
    
    im    2   ; get down!  
  
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
    ld    b, high T1GPAGE 
    out   (c), a
    
    ld    a, 8
    ld    b, high T0XOFFSL
    out   (c), a
    ld    b, high T1XOFFSL
    out   (c), a

    ;ld    a, TSU_T1EN
    ;ld    b, high TSCONFIG
    ;out   (c), a
    
    ld    a, MEM_W0WE | MEM_W0MAP_N | MEM_W0RAM
    ld    b, high MEMCONFIG
    out   (c), a
    
    xor   a
    ld    b, high PALSEL
    out   (c), a
    ld    b, high BORDER
    out   (c), a
    
    ld    a, VID_320X240 | VID_ZX | VID_NOGFX
    ld    b, high VCONFIG
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN  ; 14 MHz + cache
    ld    b, high SYSCONFIG 
    out   (c), a    
    
    ; ПОЕХАЛИИИИИИИИИИИИИИИ!!!!! :)

    ld    bc, 0
    ei                      ; можно не бояться, что нас выкинут в космос :)
frame
    halt
    
    ld    a, c
    and   1
    jp    nz, frame_skip
    
    exx
    
    ld    hl, (t0pos)
    ld    de, (t1pos)
    ld    bc, hl
    ld    hl, de
    ld    de, bc
    ld    (t0pos), hl
    ld    (t1pos), de
    
    ld    a, e
    ld    (t0posl-1), a
    ld    a, l
    ld    (t1posl-1), a
    
    ld    bc, #2C20         ; B - x counter, C - y counter (40 x 30)
    jp    y_loop
    align 512
;-----------------------------vvv    
y_loop    
;----------------vvv
; конфигурация фильтра:
;     0 1 0
;     1 0 1
;     0 1 0
x_loop    

    ld    a,(hl)            ; 7
    dec   l                 ; 4
    dec   l                 ; 4
    xor   (hl)            ; 7
    inc   l                 ; 4
    inc   l                 ; 4
    inc   l                 ; 4
    inc   l                 ; 4
    xor   (hl)            ; 7
    dec   h
    dec   l                 ; 4
    dec   l                 ; 4
    xor   (hl)            ; 7
    inc   h
    inc   h
    xor   (hl)            ; 7
    
    ld    (de), a           ; 7  
    inc   e                 ; 4
    inc   e                 ; 4
    dec   h                 ; 4
    inc   l
    inc   l

    djnz  x_loop            ; 13 
;----------------^^^        
    inc   d
    inc   h
    ld    e, 0
t0posl    
    ld    l, 0 
t1posl    
    dec   c
    ld    b, #2C
    jr    nz, y_loop
;-----------------------------^^^    
    exx

    ld    h, #CF
    ;ld    a, 0
    ld    a, (t1pos)
    add   #28
    ld    l, a
    
    ld    a, c
    rra   
    rra
    rra
    rra
    and   #0F
    ld    (hl), a
    
frame_skip
    inc   bc
    
    ei
    jp    frame

   
   
int_handler
    push  af
    push  bc
    push  de
    push  hl

;    ld    a, (BeatCounter)
;    dec   a
;    ld    (BeatCounter), a
;    jr    nz, isr_bskip
;    ld    a, #40
;    ld    (PWNZ), a
;    ld    a, 23
;    ld    (BeatCounter), a
;isr_bskip

    ld    hl, (TimeCounter)
    dec   hl
    ld    (TimeCounter), hl
    
    ld    a, h
    and   #FF
    jr    nz, isr_tskip
    ld    a, l
    and   #FF
    jr    nz, isr_tskip

    ; back to resident
    
    di
    ;halt
    ld    a, #E1
    ld    bc, PAGE3
    out   (c), a
    
    ld    sp, #FFFD
    ret
    
isr_tskip
    exx
    ex    af, af' ;'
    push  af
    push  bc
    push  de
    push  hl
    exx
    ex    af, af' ;'
    ;----------------------
    
    ld    a, #E0
    ld    bc, PAGE3
    out   (c), a
    call  #C005
    
    ld    a, #20
    ld    bc, PAGE3
    out   (c), a
    
    ld    a,  (tileconf)
    xor   #60
    ld    (tileconf), a
    ld    bc, TSCONFIG
    out   (c), a    
    ;----------------------
    exx
    ex    af, af' ;'
    pop   hl
    pop   de
    pop   bc
    pop   af
    exx
    ex    af, af' ;'
    pop   hl
    pop   de
    pop   bc
    pop   af
    ei
    ret 
 

;BeatCounter     db  23
TimeCounter     dw  384
   
   
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
		db #1c,#CA
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

tileconf        db TSU_T0EN

t0pos           dw #C100
t1pos           dw #C180
                
        
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
 
        savebin "xor.$c", start, (c_end - start)