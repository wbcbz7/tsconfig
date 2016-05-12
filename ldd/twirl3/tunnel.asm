﻿

    device zxspectrum128
    include "tsconfig.asm"

    
    org   #6EFF
intvec  dw 0 
    
    org   #6000 
start
    di
    ld    sp, #6FFF   
    
    
    ld    hl, int_handler
    ld    (#6EFF), hl
    
    ld    a, #6E
    ld    i, a
    
    ld    a, INT_MSK_FRAME
    ld    bc, INTMASK
    out   (c), a
    
    im    2   ; get down!
    
    
    ld    hl,pals
    call  set_ports
    call  dma_stats
    
    ld    a, 0
    ld    b, high PALSEL
    out   (c),a
    
    ld    a, MEM_W0WE | MEM_W0MAP_N | MEM_W0RAM
    ld    b, high MEMCONFIG
    out   (c), a
    
    ld    a, #51
    ld    b, high PAGE0
    out   (c), a
   
    ld    a, #40
    ld    b, high VPAGE
    out   (c),a
    ld    b, high PAGE3
    out   (c),a    
    
    ld    hl,0		;00 - цвет, заданный в палитре
    ld    (#c000),hl
    ld    hl, fill_screen
    call  set_ports 
    call  dma_stats
    
    ld    hl, tmap_clear
    call  set_ports 
    call  dma_stats
    
    ld    hl, copy_tiles
    call  set_ports 
    call  dma_stats
    
    ld    hl, copy_1
    call  set_ports 
    call  dma_stats
    
    ld    hl, copy_2
    call  set_ports 
    call  dma_stats
    
    ld    a, 0
    ld    b, high T0XOFFSL
    out   (c), a
    ld    b, high T0XOFFSH
    out   (c), a
    ld    b, high T0YOFFSL
    out   (c), a
    ld    b, high T0YOFFSH
    out   (c), a
    
    ld    a, #20
    ld    b, high T0GPAGE
    out   (c), a
    
    ld    a, #28
    ld    b, high TMPAGE
    out   (c), a
    
    ld    a, TSU_T0EN
    ld    b, high TSCONFIG
    out   (c), a
    
    ld    a, #E0
    ld    b, high GYOFFSL
    out   (c),a

    ld    a, 1
    ld    b, high GYOFFSH
    out   (c),a        
    
    ld    a, VID_256X192 | VID_16C
    ld    b, high VCONFIG
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN ; 14 MHz + cache
    ld    b, high SYSCONFIG 
    out   (c), a   
    
    ld    bc, 0
outer
    ld    sp, #7FFF
    exx
    push  hl
    push  bc
    ld    a, #40
    ld    bc, VPAGE
    out   (c), a
    
    ld    a, (VidPage0)
    ld    (CurVidPage), a
    ld    b, high PAGE3
    out   (c),a
    
    call  dma_stats
    ld    a, (ScrOfs)
    ld    b, high DMADADDRH
    out   (c), a
    
    ;ld    b, high DMASADDRH
    ;out   (c), a
    
    xor   1
    ld    (ScrOfs), a
    
    ld    hl, copy_buf
    push  af
    call  set_ports

    pop   af
    pop   bc
    pop   hl
    exx
    ld    e, 0

    ld    a, #C0
    ld    d, a
    exx
    ld    d, a 
    exx
    ld    a, h
    
    di
    ld    sp, #8000
    ex    af, af' ;'
    ld    a, 64
    
    jp   loop
    
    align 512
loop    
    ex    af, af' ;'
    ;------------inner loop------------    
    
    exx
    ld    b, 8
inner_loop:
    exx
    dup 16
    ;-----------------vvv
    pop   hl          ; 10
    add   hl, bc      ; 11
    ld    a, (hl)     ; 7
    ld    (de), a     ; 7
    inc   de          ; 6
    ;-----------------^^^
    ; 41 t-states
    
    edup
    exx
    djnz  inner_loop
    exx
    

    ex    af, af' ;'
    dec   a   
    jr    z, endloop
    cp    32
    jp    nz, loop
flippage
    ; save stack pointer and give some time for int
    ld    hl, 0
    add   hl, sp
    ld    sp, #7FFF
    ei
    halt
    di
    ld    sp, hl
    ; then flip the video page
    ; из приколов - я ни разу не задействовал PAGE0 ;)
    ;ld    e, 0
    ;ex    af, af' ;'
    ;ld    a, (VidPage1)
    ;ld    (CurVidPage), a
    ;exx
    ;ld    bc, PAGE3
    ;out   (c), a
    ;ld    a, d
    ;exx
    ;ld    d, a
    ;ex    af, af' ;'
    jp    loop

endloop    ;вылетаем если кадр отрисован
    ex    af, af' ;'    
    ld    hl, (SinTabOfs)
    ld    c, (hl)
    inc   hl
    ld    b, (hl)
    inc   hl
    ld    (SinTabOfs), hl

    ld    a, (FrameCounter)
    inc   a
    ld    (FrameCounter), a
    
    ld    sp, #7FFF
    ei
    halt
    
    ; тут какая-то магия с fade-in и чередованием строк для интерлейса    
    ld    a, (FadeInTimeout)
    ld    d, a
    rla
    cp    16
    jr    z, blast
    exx
    ld    e, a
    sla   a
    sla   a
    sla   a
    sla   a
    ld    b, high BORDER
    out   (c), a
    sra   a
    sra   a
    and   #30
    or    e
    ld    b, high PALSEL
    out   (c), a
    exx  
    ld    a, d
    inc   a    
    ld    (FadeInTimeout), a    

    exx
    ld    a, #40
    ld    bc, VPAGE
    out   (c), a
    exx
    jr    gtfo
blast
    ld    a, (nofadein)
    inc   a
    ld    (nofadein), a
    ld    a, 15
    exx
    ld    e, a
    sla   a
    sla   a
    sla   a
    sla   a
    ld    b, high BORDER
    out   (c), a
    sra   a
    sra   a
    and   #30
    or    e
    ld    b, high PALSEL
    out   (c), a
    exx     
gtfo    
    jp    outer

    
int_handler
    di
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
    
    ld    a, (BeatCounter)
    dec   a
    ld    (BeatCounter), a
    jr    nz, isr_bskip
    ld    a, 11
    ld    (FadeInTimeout), a
    ld    a, 0
    ld    (nofadein), a
    ld    a, 24
    ld    (BeatCounter), a
isr_bskip

    ld    hl, (Beat2Counter)
    dec   hl
    ld    (Beat2Counter), hl
    
    ld    a, h
    and   #FF
    jr    nz, isr_b2skip
    ld    a, l
    and   #FF
    jr    nz, isr_b2skip

    ld    a, 8
    ld    (FadeInTimeout), a
    ld    a, 0
    ld    (nofadein), a
    ld    hl, 192
    ld    (Beat2Counter), hl
isr_b2skip  
    
    
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

    
    ld    a, #E0
    ld    bc, PAGE3
    out   (c), a
    call  #C005
    
    ld    a, (CurVidPage)
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
    
BeatCounter     db  24
Beat2Counter    dw  696
TimeCounter     dw  769
    
    
; зпiзженно у VBI ;)
set_ports	ld c,#AF
.m1		ld b,(hl) 
		inc hl
		inc b
		ret z
		outi
		jr .m1
                
dma_stats	ld b,high DMASTATUS
		in a,(c)
		AND #80
		jr nz,$-4
		ret   


pals
        db #1a, #0
        db #1b, #68
        db #1c, #C2
        db #1d, 0
        db #1e, 0
        db #1f, 0
        db #26, #FF
        db #28, 0
        db #27, DMA_RAM_CRAM     ; #84 - копирование из RAM в CRAM
        db #ff  
            
tmap_clear
        db #1a, 0	;
		db #1b, 0	;
		db #1c, #40	;
		db #1d, 0	;
		db #1e, 0	;
		db #1f, #28	;

		db #28, 24	;
		db #26, 31	;
		db #27, DMA_FILL | DMA_DALGN
		db #ff    
            
fill_screen	
        db #1a, 0	;
		db #1b, 0	;
		db #1c, #40	;
		db #1d, 0	;
		db #1e, 0	;
		db #1f, #40	;

		db #28, #FF	;
		db #26, #ff	;
		db #27, DMA_FILL
		db #ff    
                
copy_buf
        db #1a, 0
        db #1b, 0
        db #1c, #44
        db #1d, 0
        db #1f, #40

        db #28, 63
        db #26, 63
        db #27, DMA_RAM | DMA_ASZ | DMA_DALGN
        db #ff 

copy_tiles
        db #1a, 0
        db #1b, 0
        db #1c, #60
        db #1d, 0
        db #1e, 0
        db #1f, #20

        db #28, 7
        db #26, #FF
        db #27, DMA_RAM
        db #ff
        
copy_1
        db #1a, 0
        db #1b, 0
        db #1c, #61
        db #1d, 0
        db #1e, #3
        db #1f, #28

        db #28, 0
        db #26, 2
        db #27, DMA_RAM | DMA_DALGN
        db #ff
        
copy_2
        db #1a, #6
        db #1b, 0
        db #1c, #61
        db #1d, #34
        db #1e, #14
        db #1f, #28

        db #28, 0
        db #26, 5
        db #27, DMA_RAM | DMA_DALGN
        db #ff
        
CurGXYOffsH   db 0   
CurVidPage    db 0 
VidPage0      db #44
VidPage1      db #45
ScrOfs        db #C0
FrameCounter  db 0
FadeInTimeout db 0
nofadein      db 0

SinTabOfs     dw #0000  

    
    savebin "tunnel.$c", #6000, #800
;    savesna "tunnel.sna", start