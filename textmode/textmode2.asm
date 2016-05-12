;do not run under wild commander!

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
   
    ld    a, #E0
    ld    bc, PAGE3
    out   (c), a
    call  #C000
   
    ld    a, #40
    ld    bc, VPAGE
    out   (c), a
    ld    b, high PAGE3
    out   (c), a  

    ld    a, #50
    ld    b, high PAGE2
    out   (c), a    
    
    ld    a, #0
    ld    b, high GYOFFSL
    out   (c), a
    ld    b, high GYOFFSH
    out   (c), a
    ld    b, high GXOFFSL
    out   (c), a
    ld    b, high GXOFFSH
    out   (c), a
    
    ;     типо очистка экрана (через жопу :)
    ; чистим аттрибуты
    ld    hl,#0707		
    ld    (#C080),hl
    ld    a, #80
    ld    b, high DMASADDRL
    out   (c), a
    ld    b, high DMADADDRL
    out   (c), a
    ld    hl,fill_screen
    call  set_ports  

    ; чистим символы
    ld    hl,#0		;00 - цвет, заданный в палитре
    ld    (#C000),hl
    ld    a, 0
    ld    b, high DMASADDRL
    out   (c), a
    ld    b, high DMADADDRL
    out   (c), a
    ld    hl,fill_screen
    call  set_ports  
    
    ;ld    hl,copy_text
    ;call  set_ports     
    
    ld    a, VID_320X200 | VID_TEXT
    ld    b, high VCONFIG
    out   (c), a
    
    ld    a, #F0
    ld    b, high BORDER
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN  ; 14 MHz + cache
    ld    b, high SYSCONFIG 
    out   (c), a    
    
    call  unpack
    
    ei
    ld    c, #AF
    ld    hl, 0 
    ld    de, hl
loop
    
    ; hi, g0blinish! =)   
waitkey
    ld    a, #EF
    in    a, (#FE)
    and   #10
    jr    z, down
    
    ld    a, #EF
    in    a, (#FE)
    and   #8
    jr    z, up
    
    ; если ничего не нажато - сбрасываем кинетическую прокрутку
    ld    a, (k_hold)
    xor   a
    ld    (k_hold), a
    
    ld    a, (k_inc)
    xor   a
    ld    (k_inc), a
    jr    waitkey
    
down
    ld    a, (k_inc)
    cp    8
    jr    z, down_skip
    inc   a
    ld    (k_inc), a
    
down_skip
    ld    e, a
    ;ld    d, 0
    add   hl, de
    jr    blast
    
up
    ld    a, (k_inc)
    cp    8
    jr    z, up_skip
    inc   a
    ld    (k_inc), a

up_skip
    ld    e, a
    sbc   hl, de
    
blast
    halt
    ld    a, h
    ld    b, high GYOFFSH
    out   (c), a
    
    ld    a, l
    ld    b, high GYOFFSL
    out   (c), a
    jr    loop    
   

int_handler
    push  af
    push  bc
    push  de
    push  hl
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
    
    ld    a, #40
    ld    bc, PAGE3
    out   (c), a
    
    ld    bc, #FFFD
    ld    a, 9
    out   (c), a
    in    a, (c)
    and   #10
    jr    nz, beat_skip
    in    a, (c)
    
    and   #1
    or    #F0
    ld    bc, BORDER
    out   (c), a
    jr    isr_end
    
beat_skip    
    ld    a, #F0
    ld    bc, BORDER
    out   (c), a
isr_end
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
   
   
; text unpacker
unpack
    ld    hl, #8000
    ld    de, #C000

str_loop
    ld    a, (hl)
    cp    #0D
    jr    z, str_end
    ldi
    jr    str_loop
str_end
    inc   hl
    inc   hl
    inc   d
    ld    e, 0
    ld    a, (hl)
    inc   a
    jp    nz, str_loop
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
            

fill_screen;
		db #1b,0	;
		db #1c,#40	;
		;db #1d,#80	;
		db #1e,0	;
		db #1f,#40	;

		db #28,#3F	;
		db #26,#3F	;
		db #27,DMA_FILL | DMA_SALGN | DMA_DALGN
		db #ff
                
;copy_text       db #1a,0	;
;                db #1b,0	;
;                db #1c,#50	;
;                db #1d,0	;
;                db #1e,0	;
;                db #1f,#40	;

;                db #28,#3	;
;                db #26,#7F	;
;                db #27,DMA_RAM | DMA_DALGN
;                db #ff
;                

k_hold  db  0
k_inc   db  0
               
c_end               
 
        savebin "textmode2.$c", start, (c_end - start)