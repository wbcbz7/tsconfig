
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
    
    ld    a, MEM_W0WE | MEM_W0MAP_N | MEM_W0RAM
    ld    b, high MEMCONFIG
    out   (c), a 
    
    ld    a, (TablePage)
    ld    b, high PAGE0
    out   (c), a
    
    ld    a, #40
    ld    b, high PAGE3
    out   (c),a   
    
    ld    a, 0
    ld    b, high GYOFFSL
    out   (c),a

    ld    b, high GYOFFSH
    out   (c),a
    
    ld    a, VID_256X192 | VID_256C
    ld    b, high VCONFIG
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN
    ld    b, high SYSCONFIG 
    out   (c), a    
    
    ei
    ld    de, 0

frame
    halt
    
    ld   a, (ScrPageAdjust)
    xor  8
    ld   (ScrPageAdjust), a
    rrca
    rrca
    rrca
    ;xor  1
    ld   bc, GYOFFSH
    out  (c), a

    ld    a, (ScrPageAdjust)
    ld    h, #40
    add   h
    ld    (ScrPage), a
    ld    bc, PAGE3
    out   (c), a
    
    ld    b, high DMASADDRX
    out   (c), a
    
    ld    b, high DMADADDRX
    out   (c), a
    exx
    
    ld    hl, 0
    ld    (#C000), hl
    ld    hl, fill_screen
    call  set_ports
    call  dma_stats
    
line_loop
;---------------------- цикл ху€чинга линий :)
    ld    hl, (TableOfs)
line_fetch    
    ld    a, (hl)         ; т€нем номер страницы
    inc   hl
    
    cp    #FF
    jr    z, quit         ; конец фрейма
    cp    #FE
    jr    z, new_page     ; конец фрейма + переключить страницу
    
    cp    #F2
    jr    z, line_fetch
    cp    #F3
    jr    z, line_fetch
    cp    #F4
    jr    z, line_fetch

    ld    e, a
    ld    a, (ScrPageAdjust)
    add   e
    ld    b, high PAGE3
    out   (c), a
    
    ld    a, (hl)         ; т€нем младший байт адреса
    inc   hl
    ld    e, a
    ld    a, (hl)         ; т€нем старший байт адреса
    inc   hl
    ld    d, a
    push  de              ; outta space!
    
    ld    a, (hl)         ; т€нем цвет (а нахрена? :)
    inc   hl
    ld    d, a
    ld    e, 0
    push  de
    
    ld    a, (hl)         ; т€нем длину линии
    inc   hl
    ld    d, a
    ld    a, (hl)         ; т€нем инкремент
    inc   hl
    ld    e, a
    push  de
    
    ld    (TableOfs), hl  
    
    ; ’*я !
    exx
    pop   bc
    pop   hl
    pop   de
    call  y_line
proc_mod                 ; адрес дл€ модификации
    exx
    
    jr    line_loop
    
new_page    
    ld    a, (TablePage)
    ;inc   a
    ld    bc, PAGE0
    out   (c), a
    ld    (TablePage), a
    ld    hl, 0
    ld    (TableOfs), hl
    
    ;ld    de, #C080      ; line start address
    ;ld    bc, #BFFF      ; B - line length, C - 0:8 fixedpoint increment
    ;ld    hl, #FF00      ; H - line color,  L - fractinal portion of address
    
quit
    ;inc   de
    jp    frame
  
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
    
    ld    a, #40
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
        db #1d, 0
        db #1e, 0
        db #28, #BF
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
                
TableOfs        dw #0000
TablePage       db #70
ScrPageStart    db #40
ScrPage         db #40
ScrPageAdjust   db #0

c_end
    
    savebin "wf.$c", #4000, (c_end - start)