
    device zxspectrum128
    include "tsconfig.asm"

    
    org   #6EFF
intvec  dw 0 
    
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
    
    ld    hl, pals
    call  set_ports
    call  dma_stats
    
    ld    a, #40
    ld    bc, VPAGE
    out   (c),a
    
    ld    a, #40
    ld    b, high PAGE3
    out   (c),a   
    
    ld    hl, 0		;00 - цвет, заданный в палитре
    ld    (#c000), hl
    ld    hl, fill_screen
    call  set_ports
    call  dma_stats
    
    ld    a, 0
    ld    b, high GYOFFSL
    out   (c),a

    ld    b, high GYOFFSH
    out   (c),a
    
    ld    a, VID_320X240 | VID_256C
    ld    b, high VCONFIG
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN
    ld    b, high SYSCONFIG 
    out   (c), a    
    
    ei
    ld    de, 0
    exx

loop
    exx
    ld    a, #40
    ld    (ScrPage), a
    ld    bc, PAGE3
    out   (c), a
    exx
    
    ld    de, #C080      ; line start address
    ;ld    bc, #BFFF      ; B - line length, C - 0:8 fixedpoint increment
    ld    b,  #FF
    exx
    ld    a, e
    exx
    ld    c, a
    ;ld    hl, #FF00      ; H - line color,  L - fractinal portion of address
    ld    h, a
    ld    l, 0
    xor   a
    
    call  y_line

    ;di
    halt        ; :p
    exx
    inc   de
    exx
    jp    loop
  
x_line    
    ; tryin' to write it :)
    ld    a, l
    add   c
    ld    l, a
    jr    nc, x_no_inc
    inc   d
    inc   d
    jr    nz, x_no_switch
    exx
    ld    a, (ScrPage)
    inc   a
    ld    (ScrPage), a
    ld    bc, PAGE3
    out   (c), a
    exx
    ld    d, #C0
x_no_switch
x_no_inc
    ld    a, h
    ld    (de), a
    inc   e                  ; inc\dec e for direction change
    djnz  x_line
    ret
  
y_line
    ; tryin' to write it :)
    ld    a, l
    add   c
    ld    l, a
    jr    nc, y_no_inc
    inc   e                  ; inc\dec e for direction change
y_no_inc
    ld    a, h
    ld    (de), a
    inc   d
    inc   d
    jr    nz, y_no_switch
    exx
    ld    a, (ScrPage)
    inc   a
    ld    (ScrPage), a
    ld    bc, PAGE3
    out   (c), a
    exx
    ld    d, #C0
y_no_switch
    djnz  y_line
    ret
    
int_handler
    push  af
    push  bc
    push  de
    push  hl

    ;ld    hl, (TimeCounter)
    ;dec   hl
    ;ld    (TimeCounter), hl
    
    ;ld    a, h
    ;and   #FF
    ;jr    nz, isr_tskip
    ;ld    a, l
    ;and   #FF
    ;jr    nz, isr_tskip
    ; back to resident
    
    ;di
    ;halt
    ;ld    a, #E1
    ;ld    bc, PAGE3
    ;out   (c), a
    
    ;ld    sp, #FFFD
    ;ret
    
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
    
    ;ld    a, #E0
    ;ld    bc, PAGE3
    ;out   (c), a
    ;call  #C005
    
    ld    a, #48
    ld    bc, PAGE3
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
 

BeatCounter     dw  72
Beat2Counter    dw  24
TimeCounter     dw  648
    
    
; зпiзженно у VBI ;)
set_ports	ld c,#AF
.m1		ld b,(hl) 
		inc hl
		inc b
		ret z
		outi
		jr .m1
                ; dma_stats вызывать ¬–”„Ќ”ё!

dma_stats	ld b,high DMASTATUS
		in a,(c)
		AND #80
		jr nz,$-4
		ret   


pals		
        db #1a, #0
        db #1b, #68
        db #1c, #5
        db #1d, 0
        db #1e, 0
        db #1f, 0
        db #26, #FF
        db #28, 0
        db #27, DMA_RAM_CRAM     ; #84 - копирование из RAM в CRAM
        db #ff  

fill_screen	
        db #1a, 0
        db #1b, 0
        db #1c, #40
        db #1d, 0
        db #1e, 0
        db #1f, #40
        db #28, #FF
        db #26, #7F
        db #27, DMA_FILL | DMA_DALGN | DMA_ASZ
        db #ff

copy_screen
        db #1a, 0
        db #1b, 0
        db #1c, #48
        db #1d, 0
        db #1e, 0
        db #1f, #40
        db #28, #FF
        db #26, #7F
        db #27, DMA_RAM | DMA_DALGN | DMA_ASZ
        db #ff 

put_spr_setup
        db #1a, 0   
        db #1b, 0
        db #1c, #74
        db #26, 7
        db #28, 15
        db #ff

PWNZ            db #F0
PWNe            db 0
                
StartPage       db #48
ScrPage         db #48
TableOfs        dw #0000
TablePage       db #70
ScrPageAdjust   db #0

c_end
    
    savebin "dda_line.$c", #4000, (c_end - start)