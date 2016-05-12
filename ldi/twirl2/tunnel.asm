

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
    
    ld    bc, INTMASK
    ld    a, INT_MSK_FRAME
    out   (c), a
    
    im    2   ; get down!
    
    
    ld    hl,pals
    call  set_ports
    call  dma_stats
    
    ld    a, 0
    ld    bc,PALSEL
    out   (c),a
   
    ld    a, #40
    ld    bc,VPAGE
    out   (c),a
    ld    bc,PAGE3
    out   (c),a    
    
    ld    hl,0		;00 - цвет, заданный в палитре
    ld    (#c000),hl
    ld    hl,fill_screen
    call  set_ports 
    call  dma_stats
    
    ld    a, #E0
    ld    bc,GYOFFSL
    out   (c),a

    ld    a, 1
    ld    b, high GYOFFSH
    out   (c),a        
    
    ld    a,%00000001
    ld    bc,VCONFIG
    out   (c), a
    ld    a,%00000110  ; 14 MHz + cache
    ld    bc,SYSCONFIG 
    out   (c), a    
    
    
    ld    bc, 0
outer
    ld    sp, #7FFF
    exx
    push  hl
    push  bc
    ld    a, (VidPage0)
    ld    (CurVidPage), a
    ld    bc,PAGE3
    out   (c),a
    
    call  dma_stats
    ld    a, (ScrOfs)
    ld    b, high DMADADDRH
    out   (c), a
    
    ld    b, high DMASADDRH
    out   (c), a
    
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

;    jr    z,interlace
;    inc   d
;interlace
    ld    d, a
    exx
    ld    d, a 
    exx
    ld    a, h
;    exx
;    ld    bc, GYOFFSH
;    out   (c), a
;    exx
    di
    ld    sp, #8000
    ex    af, af' ;'
    ld    a, 64
;    ex    af, af'
    ;'
loop    
    ex    af, af' ;'
    ;------------inner loop------------    
    
    exx
    ld    b, 8
inner_loop:
    exx
    dup 16
    pop   hl
    add   hl, bc
    ld    a, (hl)
    ld    (de), a
    inc   de
    edup
    exx
    djnz  inner_loop
    exx
    

    inc   d
    inc   d
    ld    e, 0
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
    ld    e, 0
    ex    af, af' ;'
    ld    a, (VidPage1)
    ld    (CurVidPage), a
    exx
    ld    bc, PAGE3
    out   (c), a
    ld    a, d
    exx
    ld    d, a
    ex    af, af' ;'
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
    ld    bc, PALSEL
    out   (c), a
    sla   a
    sla   a
    sla   a
    sla   a
    ld    b, high BORDER
    out   (c), a
    exx  
    ld    a, d
    inc   a    
    ld    (FadeInTimeout), a    

    jr    gtfo
blast
    ld    a, (nofadein)
    inc   a
    ld    (nofadein), a
    ld    a, 15
    exx
    ld    bc, PALSEL
    out   (c), a
    sla   a
    sla   a
    sla   a
    sla   a
    ld    b, high BORDER
    out   (c), a
    exx     
gtfo    
    jp    outer

    
int_handler
    push  af
    push  bc
    push  de
    push  hl
    
    ld    a, (BeatCounter)
    dec   a
    ld    (BeatCounter), a
    jr    nz, isr_bskip
    ld    a, 5
    ld    (FadeInTimeout), a
    ld    a, 0
    ld    (nofadein), a
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
TimeCounter     dw 960
    
    
; зпiзженно у VBI ;)
set_ports	ld c,#AF
.m1		ld b,(hl) 
		inc hl
		inc b
		jr z,dma_stats
		outi
		jr .m1
                ret
                
dma_stats	ld b,high DMASTATUS
		in a,(c)
		AND #80
		jr nz,$-4
		ret   


pals		db #1a, #0
	        db #1b, #68
		db #1c, #86
	        db #1d, 0
	        db #1e, 0
	        db #1f, 0
	        db #26, #FF
	        db #28, 0
	        db #27, DMA_RAM_CRAM     ; #84 - копирование из RAM в CRAM
		db #ff  
            

fill_screen	defb #1a, 0	;
		defb #1b, 0	;
		defb #1c, #40	;
		defb #1d, 0	;
		defb #1e, 0	;
		defb #1f, #40	;

		defb #28, #FF	;
		defb #26, #ff	;
		defb #27, %00000100
		db #ff    
                
copy_buf	db #1a, 0	;
		db #1c, #44	;
		db #1d, 0	;
		db #1f, #40	;

		db #28, 63	;
		db #26, 63	;
		db #27, DMA_RAM | DMA_ASZ | DMA_SALGN | DMA_DALGN
		db #ff 
        
CurGXYOffsH   db 0   
CurVidPage    db 0 
VidPage0      db #44
VidPage1      db #45
ScrOfs        db #C0
FrameCounter  db 0
FadeInTimeout db 0
nofadein      db 0

SinTabOfs     dw #7000  

    
    savebin "tunnel.$c", #6000, #800
;    savesna "tunnel.sna", start