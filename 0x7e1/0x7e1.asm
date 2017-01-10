    device zxspectrum128
    include "tsconfig.asm"

    org     #6EFF
intvec      dw  0 
    
    org     #4000 
start
    di
    ld      sp, #7FFF   
    
    ; setup vertical int vector
    ld      hl, int_handler
    ld      (#6EFF), hl
    
    ld      a, #6E
    ld      i, a
    
    ld      bc, INTMASK
    ld      a, INT_MSK_FRAME
    out     (c), a
    
    im      2
    
    ; clear vars
    xor     a
    ld      b, high GXOFFSL
    out     (c),a
    ld      b, high GXOFFSH
    out     (c),a
    ld      b, high GYOFFSL
    out     (c),a
    ld      b, high GYOFFSH
    out     (c),a
    ld      b, high T0XOFFSL
    out     (c),a
    ld      b, high T0XOFFSH
    out     (c),a
    ld      b, high T0YOFFSL
    out     (c),a
    ld      b, high T0YOFFSH
    out     (c),a
    ld      b, high T1XOFFSL
    out     (c),a
    ld      b, high T1XOFFSH
    out     (c),a
    ld      b, high T1YOFFSL
    out     (c),a
    ld      b, high T1YOFFSH
    out     (c),a
    ld      b, high BORDER
    out     (c),a
    
    ; setup memory mode
    
    ld      a, MEM_W0WE | MEM_W0MAP_N | MEM_W0RAM
    ld      b, high MEMCONFIG
    out     (c), a
    
    ; setup gfx pages
    ; 0x10 - bg gfx
    ; 0x20 - tile0
    ; 0x30 - tile1
    ; 0x40 - tilemap - page0
    ld      a, 0x10
    ld      b, high VPAGE
    out     (c),a
    ld      a, 0x20
    ld      b, high T0GPAGE
    out     (c),a
    ld      a, 0x30
    ld      b, high T1GPAGE
    out     (c),a
    ld      a, 0x40
    ld      b, high TMPAGE
    out     (c),a
    ld      b, high PAGE0
    out     (c),a       
    
    ld      a, 0xF
    ld      b, high PAGE2
    out     (c),a    
    
    ; setup palettes
    ld      a, 0xC0 | 0x20 | 0xB
    ld      b, high PALSEL
    out     (c), a
    
    ; setup video mode and system config
    ld      a, TSU_T1EN | TSU_T0EN
    ld      b, high TSCONFIG
    out     (c), a
    
    ld      a, SYS_ZCLK14 | SYS_CACHEEN
    ld      b, high SYSCONFIG
    out     (c), a
    
    ld      a, VID_16C | VID_320X240
    ld      b, high VCONFIG 
    out     (c), a
    
    ld      a, 0xE0
    ld      bc, PAGE3
    out     (c), a
    call    0xC000
    
    ; clear tilemap
    ld      hl, 0x0000
    ld      (0x0), hl
    ld      hl, clear_tmap
    call    set_ports
    call    dma_stats
    
    ; set palette and copy picture
    ld      hl, pal
    call    set_ports
    call    dma_stats
    
    ; fill background
bgfill
    ld      e, 8
.loop    
    ld      a, e
    dec     a
    or      0x10
    ld      b, high DMADADDRX
    out     (c), a
    
    ld      hl, bg_fill
    call    set_ports
    call    dma_stats
    
    dec     e
    jr      nz, .loop
    
    ei
    ld      bc, 0
    ld      ix, 0
outer
    halt
    exx
    
scroll
    ld    hl, (scrollpos)
    inc   hl
    inc   hl
    ld    (scrollpos), hl
    
    ld    a, h
    ld    bc, GYOFFSH
    out   (c), a
    
    ld    a, l
    ld    b, high GYOFFSL
    out   (c), a
    
print
    ld    hl, (print_v.timeout)
    dec   hl
    ld    (print_v.timeout), hl
    
    ld    a, h
    and   #FF
    jr    nz, .end2
    ld    a, l
    and   #FF
    jr    nz, .end2

.start
    ; text hujak
    ld    hl, (print_v.textpos)
    ld    de, (print_v.tilepos)

.str_loop
    ld    a, (hl)
    inc   hl
    cp    #FF         ; конец и луп на начало
    jr    z, .str_reset
    cp    #1B         ; луп на начало
    jr    z, .str_cls
    cp    #0D         ; перевод строки
    jr    z, .str_end
    cp    #7F         ; задержка
    jr    z, .delay
    ld    (de), a
    inc   e
    inc   e
    jr    .end
.str_end
    inc   hl
    inc   d
    ld    e, 0x80
    jr    .end
.delay
    ld    (print_v.textpos), hl
    ld    hl, 200
    jr    .enddelay
.str_reset
    ld    hl, 0x8000
.str_cls
    ld    de, 0x1080
.end
    ld    (print_v.textpos), hl
    ld    (print_v.tilepos), de
    ld    hl, 1
.enddelay
    ld    (print_v.timeout), hl
.end2
    
    
plasma
    ld      h, 0x60           ; sintab offset
    exx
    ld      h, 0x60           ; sintab offset
    exx
    ld      de, 0x0000        ; start pos
    
    ld      bc, #2D0F         ; B - x counter, C - y counter (45 x 36)
    jp      .y_loop
    align   512
;-----------------------------vvv    
.y_loop    
;----------------vvv
.x_loop    

    push    bc

    ld      a, b
    sll     a
    add     c
    srl     a
    
    add     ixl
    
    exx
    add     c
    exx
        
    ld      l, a
    ld      a, (hl)
    
    ld      l, a   
    
    sll     b
    
    ld      ixl, b
    ld      ixh, c
    exx
    ld      a, ixl
    ld      l, a
    add     l
    sll     a
    ld      a, ixh
    sub     l
    sub     c
    ld      l, a
    ld      a, (hl)
    exx
    
    add     l
    add     0x1
    ld      (de), a
    
    inc     e
    inc     e

    pop     bc
    
    djnz    .x_loop            ; 13 
;----------------^^^        
    inc     d
    ld      e, 0
    dec     c
    ld      b, #2D
    jr      nz, .y_loop
;-----------------------------^^^    
   

    exx
    inc     bc
    inc     ixl
    ei
    
    jp      outer


int_handler
    push    af
    push    bc
    push    de
    push    hl
    exx
    ex      af, af' ;'
    push    af
    push    bc
    push    de
    push    hl
    
    ; your code here
    ld      a, 0xE0
    ld      bc, PAGE3
    out     (c), a
    call    0xC005
    
    ld    bc, #FFFD
    ld    a, 9
    out   (c), a
    in    a, (c)
    and   #10
    jr    nz, beat_skip
    in    a, (c)
    
    cp    15
    jr    nz, beat_skip
    ld    a, #B1
    ld    bc, BORDER
    out   (c), a
    jr    isr_end
    
beat_skip    
    ld    a, #B0
    ld    bc, BORDER
    out   (c), a
    
isr_end
    pop     hl
    pop     de
    pop     bc
    pop     af
    exx
    ex      af, af' ;'
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei
    ret 
    

print_v
.textpos   dw 0x8000
.tilepos   dw 0x1080
.timeout   dw 20
    
scrollpos  dw 0
    
; зпiзженно у VBI ;)
set_ports
    ld      c, #AF
.m1
    ld      b, (hl) 
    inc     hl
    inc     b
    ret     z
    outi
    jr      .m1

dma_stats
    ld      b, high DMASTATUS
    in      a,(c)
    and     #80
    jr      nz, dma_stats
    ret   
    
pal
    db high DMASADDRL, 0
    db high DMASADDRH, 0
    db high DMASADDRX, #90
    db high DMADADDRL, 0
    db high DMADADDRH, 0
    db high DMADADDRX, #90
    db high DMALEN   , #FF
    db high DMANUM   , 0
    db high DMACTRL  , DMA_RAM_CRAM
    db #FF  
        
clear_tmap
    db high DMASADDRL, 0
    db high DMASADDRH, 0
    db high DMASADDRX, #40
    db high DMADADDRL, 0
    db high DMADADDRH, 0
    db high DMADADDRX, #40
    db high DMALEN   , #FF
    db high DMANUM   , #1F
    db high DMACTRL  , DMA_FILL
    db #FF  
    
bg_fill
    db high DMASADDRL, 0
    db high DMASADDRH, 0
    db high DMASADDRX, #80
    db high DMADADDRL, 0
    db high DMADADDRH, 0
    db high DMALEN   , 79
    db high DMANUM   , 63
    db high DMACTRL  , DMA_RAM | DMA_DALGN
    db #FF  
    
end

    savebin "0x7e1.$c", start, (end - start)