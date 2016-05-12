
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
    ld    hl, 0		;00 - цвет, заданный в палитре
    ld    (#c000), hl
    ld    hl, fill_screen
    call  set_ports
   
    ld    a, #40
    ld    bc, VPAGE
    out   (c),a
    ld    b, high PAGE3
    out   (c),a   

    ld    a, MEM_W0WE | MEM_W0MAP_N | MEM_W0RAM
    ld    b, high MEMCONFIG
    out   (c), a   
    
    ld    a, (TablePage)
    ld    b, high PAGE0
    out   (c), a
    
    ld    a, VID_320X200 | VID_256C
    ld    b, high VCONFIG
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN
    ld    b, high SYSCONFIG 
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
    
    ; подготовка - очистка экрана и загрузка нужных регистров
    
spr_loop
;---------------------- цикл обработки спрайтов
    call  dma_stats
    ld    hl, put_spr_setup
    call  set_ports
    ld    hl, (TableOfs)
    ld    d, 0
    ld    a, (hl)
    inc   hl
    cp    #FF
    jr    nz, skip1
    inc   d
skip1
    ld    b, high DMADADDRL
    out   (c), a
    
    ld    a, (hl)
    inc   hl
    cp    #FF
    jp    z, check
skip2
    ld    b, high DMADADDRH
    out   (c), a

    ld    a, (hl)
    ld    e, a
    ld    a, (ScrPageAdjust)
    add   e
    inc   hl
    ld    b, high DMADADDRX
    out   (c), a
    
    ld    a, DMA_BLT2 | DMA_DALGN | DMA_ASZ | #40
    ld    b, high DMACTRL
    out   (c), a
    ld    (TableOfs), hl  
    jr    spr_loop
    
quit
    ld    a, (hl)
    cp    #FE
    jr    nz, skip_quit
    
    ld    a, (TablePage)
    inc   a
    and   #73
    ld    b, high PAGE0
    out   (c), a
    ld    (TablePage), a
    ld    hl, 0
    
    
skip_quit
    ld    (TableOfs), hl  
    
    call  dma_stats
   
    exx
    inc   bc
    ld    a, c
    and   1
    exx
    rlca
    rlca
    rlca
    ld    (ScrPageAdjust), a
    or    #40
    ld    b, high DMASADDRX
    out   (c), a
    ld    b, high DMADADDRX
    out   (c), a
    ld    b, high PAGE3
    out   (c), a
    
    ;дальше идет ПИЗДЕЦ
    
    ;ld    a, (PWNZ)
    ;and   #FF
    ;jr    z, skip
    ;;xor   a
    ;ld    h, a
    ;ld    l, h
    ;sub   #10
    ;ld    (PWNZ), a
    ;jr    sk2
;skip
    ;xor   a
    ;ld    h, a
    ;ld    l, h
;sk2   
    ;ld    a, (PWNe)
    ;dec   a
    ;ld    (PWNe), a
    ;jp    z, sk4
    
    ;ld    a, l
    ;jr    z, sk3
    ;;add   #10
;sk3
    ;ld    b, high BORDER
    ;out   (c), a
    ;;sub   #10
 
;sk4 
    ld    hl, 0 ; фикс для ПИЗДЕЦА
    ld    (#c000), hl
    ld    hl, fill_fbuf
    call  set_ports
    exx
    jp    frame

check
    ld    e, a
    ld    a, d
    and   1
    jr    nz, quit
    ld    a, e
    jr    quit    

    ; а тут - еще больший ПИЗДЕЦ
    
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
    
    ;ld    hl, (BeatCounter)
    ;dec   hl
    ;ld    (BeatCounter), hl
   
    ;ld    a, h
    ;and   #FF
    ;jr    nz, isr_bskip
    ;ld    a, l
    ;and   #FF
    ;jr    nz, isr_bskip
    ;ld    a, #F0
    ;ld    (PWNZ), a
    
    ;;ld    a, 23
    ;;ld    (BeatCounter), a
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
    halt
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
                ; dma_stats вызывать ВРУЧНУЮ!

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
        db #26, #FF
        db #27, DMA_FILL
        db #ff

fill_fbuf
        db #1a, 0
        db #1b, 0
        db #1d, 0
        db #1e, 0
        db #28, #C7
        db #26, #9F
        db #27, DMA_FILL | DMA_DALGN | DMA_ASZ
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
                
ScrPage         db #40
TableOfs        dw #0000
TablePage       db #70
ScrPageAdjust   db #0

c_end
    
    savebin "3dstuff.$c", #4000, (c_end - start)