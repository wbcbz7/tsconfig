; page - #C4
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
    
    xor   a
    ld    bc, DMASADDRH
    out   (c), a
    ld    hl, pals
    call  set_ports
    
    ld    a, VID_NOGFX
    ld    b, high VCONFIG
    out   (c), a
    
    xor   a
    ld    b, high TSCONFIG
    out   (c), a
    
    call  dma_stats
    ld    hl, 0		;00 - цвет, заданный в палитре
    ld    (#c000), hl
    ld    hl, fill_screen
    call  set_ports
   
    ld    a, #40
    ld    bc, VPAGE
    out   (c),a
   
    ld    a, MEM_W0WE | MEM_W0MAP_N | MEM_W0RAM
    ld    b, high MEMCONFIG
    out   (c), a   
    
    ld    a, VID_256X192 | VID_256C
    ld    b, high VCONFIG
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN
    ld    b, high SYSCONFIG 
    out   (c), a    
    
    xor  a
    ld   b, high BORDER
    out  (c), a
    
    ld    a, 32
    ld    b, high GXOFFSL
    out   (c), a
    
    ld    a, 0
    ld    b, high TSCONFIG
    out   (c), a
    
    ;call  make_noize ; :)
    
    ld    a, #40
    ld    b, high PAGE3
    out   (c),a   
    
    ld    a, (TablePage)
    ld    b, high PAGE0
    out   (c), a
    
    ei
    ld    bc, 0
frame
    halt
    exx
    
    ld   a, (ScrPageAdjust)
    ;xor  8
    ;ld   (ScrPageAdjust), a
    rrca
    rrca
    rrca
    ;xor  1
    ld   bc, GYOFFSH
    out  (c), a
    
    ; гребаная моргалка
    
    ld   a, (PWNZ)
    and  a
    jr   z, spr_loop
    ld   b, high BORDER
    out  (c), a
    
    push af
    rra
    rra
    rra
    ld   b, high GYOFFSL
    out  (c), a
    
    dec   a
    dec   a
    ld    b, high DMASADDRH
    out   (c), a
    ld    hl, pals
    call  set_ports
    
    pop  af
    sbc  #10
    ld   (PWNZ), a
    
    ; подготовка - очистка экрана и загрузка нужных регистров
    
spr_loop
;---------------------- цикл обработки спрайтов
    call  dma_stats
    ld    hl, put_spr_setup
    call  set_ports
    ld    hl, (TableOfs)
    
    ld    a, (hl)         ; тянем номер страницы
    inc   hl
    
    cp    #FF
    jr    z, quit         ; конец фрейма
    cp    #FE
    jr    z, new_page     ; конец фрейма + переключить страницу
    cp    #FD
    jr    z, first_page   ; конец фрейма + начать сначала

    ld    e, a
    ld    a, (ScrPageAdjust)
    add   e
    ld    b, high DMADADDRX
    out   (c), a
    
    ld    a, (hl)         ; тянем младший байт адреса
    inc   hl

    ld    b, high DMADADDRL
    out   (c), a
    
    ld    a, (hl)         ; тянем старший байт адреса
    inc   hl

    ld    b, high DMADADDRH
    out   (c), a
    
    ; Х*ЯК!
    
    ld    a, DMA_BLT2 | DMA_DALGN | DMA_ASZ | #40
    ld    b, high DMACTRL
    out   (c), a
    ld    (TableOfs), hl  
    jr    spr_loop
    
new_page    
    ld    a, (TablePage)
    inc   a
    ld    bc, PAGE0
    out   (c), a
    ld    (TablePage), a
    ld    hl, 0
    jr    quit
    
first_page
    ld    a, (TablePage)
    and   #F0
    ld    bc, PAGE0
    out   (c), a
    ld    (TablePage), a
    ld    hl, 0
    jr    quit
 
 
quit
    ld    (TableOfs), hl  
    
    call  dma_stats
   
    exx
    inc   bc
    ld    a, c
    push  af
    and   1
    exx
    rlca
    rlca
    rlca
    ld    (ScrPageAdjust), a
    or    #40
    ld    b, high DMADADDRX
    out   (c), a
    ld    b, high PAGE3
    out   (c), a
      
    pop   af
    and   7
    or    #D0
    ld    b, high DMASADDRX
    out   (c), a
    
    call  FastGalois16
    ld    b, high DMASADDRH
    out   (c), a
    
    ;ld    hl, 0 ; фикс для ПИЗДЕЦА
    ;ld    (#c000), hl
    ld    hl, fill_fbuf
    call  set_ports
    exx
    jp    frame

    
int_handler
    push  af
    push  bc
    push  de
    push  hl

    ;ld    hl, (Beat2Counter)
    ;dec   hl
    ;ld    (Beat2Counter), hl
   
    ;ld    a, h
    ;and   #FF
    ;jr    nz, isr_b2skip
    ;ld    a, l
    ;and   #FF
    ;jr    nz, isr_b2skip
    ;ld    a, #40
    ;ld    (PWNZ), a
    ;ld    a, 1
    ;ld    (PWNe), a
    ;ld    a, 24
    ;ld    (Beat2Counter), a
;isr_b2skip
    
    ld    hl, (BeatCounter)
    dec   hl
    ld    (BeatCounter), hl
   
    ld    a, h
    and   #FF
    jr    nz, isr_bskip
    ld    a, l
    and   #FF
    jr    nz, isr_bskip
    ld    a, #40
    ld    (PWNZ), a
    
    ld    a, 24
    ld    (BeatCounter), a
isr_bskip

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
    
make_noize
    ; generation da famous >>white noise<< :)
    ld   a, #D0
    push af
    ld   b, high PAGE3
    out  (c), a
    
    ld   b, 16
    push bc
    
n_setup    
    ld   de, #C000
    ld   bc, #3FFF
    
n_loop
    call FastGalois16
    and  #3F
    add  #10              ; чтобы не пересекалось с тайлами
    ld   (de), a
    dec  bc
    inc  de
    
    ld   a, b
    and  a
    jp   nz, n_loop
    
    ld   a, c
    and  a
    jp   nz, n_loop
    
    ; switch page
    pop  bc
    pop  af
    dec  b
    ret  z
    
    inc  a
    push af
    push bc
    ld   bc, PAGE3
    out  (c), a
    
    jr   n_setup

    
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


BeatCounter     dw  24
Beat2Counter    dw  24
TimeCounter     dw  384
    
    
; зпiзженно у VBI ;)
set_ports	ld c,#AF
.m1		ld b,(hl) 
		inc hl
		inc b
		ret z
		outi
		jr .m1
                ; dma_stats вызывать ВРУЧНУЮ!

dma_stats	ld b,high DMASTATUS
		in a,(c)
		AND #80
		jr nz,$-4
		ret   


pals		
        db #1a, #0
        ;db #1b, #68
        db #1c, #C5
        db #1d, 0
        db #1e, 0
        db #1f, 0
        db #26, #FF
        db #28, 0
        db #27, DMA_RAM_CRAM     ; #84 - копирование из RAM в CRAM
        db #ff  

fill_screen	
;        db #1a, 0
;        db #1b, 0
;        db #1c, #40
;        db #1d, 0
;        db #1e, 0
;        db #1f, #40
;        db #28, #FF
;        db #26, #FF
;        db #27, DMA_FILL
        db #ff

fill_fbuf
        db #1a, 0
        db #1d, 0
        db #1e, 0
        db #28, #CF
        db #26, #9F
        db #27, DMA_RAM | DMA_DALGN | DMA_ASZ
        db #ff 

put_spr_setup
        db #1a, 0   
        db #1b, 0
        db #1c, #73
        db #26, 7
        db #28, 15
        db #ff

PWNZ            db #40
PWNe            db 0
                
ScrPage         db #40
TableOfs        dw #0000
TablePage       db #70
ScrPageAdjust   db #0

c_end
    
    savebin "3dstuff.$c", #4000, (c_end - start)