;do not run under wild commander!

    device zxspectrum128
    include "tsconfig.asm"

    
    org   #4000 
start
    di
    ld    sp, #7FFF   
    
    ld    hl, int_start
    ld    (#6EFF), hl
    
    ld    a, #6E
    ld    i, a
    
    ld    bc, INTMASK
    ld    a, INT_MSK_FRAME
    out   (c), a
    
    im    2   ; get down! 
   
    ;ld    a, #E0
    ;ld    bc, PAGE3
    ;out   (c), a
    ;call  #C000
   
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
    
    ; типо очистка экрана (через жопу :)
    ; ставим страницу
    ;ld    a, #42
    ;ld    b, high DMASADDRX
    ;out   (c), a
    ;ld    b, high DMADADDRX
    ;out   (c), a
    ;ld    b, high PAGE3
    ;out   (c), a  
    
    ; чистим аттрибуты
    ;ld    hl,#9F9F		
    ;ld    (#C080),hl
    ;ld    a, #80
    ;ld    b, high DMASADDRL
    ;out   (c), a
    ;ld    b, high DMADADDRL
    ;out   (c), a
    ;ld    hl,fill_screen
    ;call  set_ports  

    ; опять ставим страницу (говнокод! :)
    ;ld    a, #42
    ;ld    b, high DMASADDRX
    ;out   (c), a
    ;ld    b, high DMADADDRX
    ;out   (c), a
    
    ; чистим символы
    ;ld    hl,#0		;00 - цвет, заданный в палитре
    ;ld    (#C000),hl
    ;ld    a, 0
    ;ld    b, high DMASADDRL
    ;out   (c), a
    ;ld    b, high DMADADDRL
    ;out   (c), a
    ;ld    hl,fill_screen
    ;call  set_ports  
    
    ; типо очистка экрана (через жопу :)
    ; ставим страницу
    ld    a, #40
    ld    b, high DMASADDRX
    out   (c), a
    ld    b, high DMADADDRX
    out   (c), a
    ld    b, high PAGE3
    out   (c), a  
    
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

    ; опять ставим страницу (говнокод! :)
    ld    a, #40
    ld    b, high DMASADDRX
    out   (c), a
    ld    b, high DMADADDRX
    out   (c), a
    
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
    
    
    ld    hl,copy_font
    call  set_ports     
    
    ld    a, VID_320X240 | VID_TEXT
    ld    b, high VCONFIG
    out   (c), a
    
    ld    a, #F0
    ld    b, high BORDER
    out   (c), a
    
    ld    a, SYS_ZCLK14 | SYS_CACHEEN  ; 14 MHz + cache
    ld    b, high SYSCONFIG 
    out   (c), a    
    
    call  unpack
    
    ld    hl
    
    ei
    halt
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

    ld    a, (k_inc)
    or    a
    jp    z, waitkey
    
    dec   a
    ld    (k_inc), a
    
    ld    e, a
    ld    a, (k_dir)
    or    a
    ld    a, e
    jr    z, down_skip
    jr    up_skip
    
down
    ld    a, 0
    ld    (k_dir), a
    
    ld    a, (k_inc)
    cp    16
    jr    z, down_skip
    inc   a
    ld    (k_inc), a
    
down_skip
    ld    e, a
    add   hl, de
    jr    blast
    
up
    ld    a, 1
    ld    (k_dir), a
    
    ld    a, (k_inc)
    cp    16
    jr    z, up_skip
    inc   a
    ld    (k_inc), a

up_skip
    ld    e, a
    sbc   hl, de
    
blast
    ld    a, (int_poll)
    dec   a
    halt
    jr    z, blast   
    
    ld    (int_poll), a
    
    ; проверим на переключение страницы
;    push  hl
;    ld    a, h
;    and   #20
;    ld    h, a
    
;    ld    (scr_pos+1), a
;    and   #20
;    cp    h
;    jr    nz, skip_switch
    
    ; переключаем страницу
;    or    a
;    jr    z, dma_second
;dma_first
    ; переход с 31-й на 32-ю строку, заполняем первую половину
;    ld    a, (unpack_page)
;    inc   a
;    ld    (unpack_page), a
;    ld    bc, DMASADDRX
;    out   (c), a
    
;    ld    a, 0
;    ld    b, high DMASADDRH
;    out   (c), a
;    ld    b, high DMADADDRH
;    out   (c), a
    
;    ld    hl, copy_text
;    call  set_ports
    
;    jr    skip_switch
 
;dma_second
    ; переход с 63-й на 0-ю строку, заполняем вторую половину
;    ld    a, (unpack_page)
;    ld    bc, DMASADDRX
;    out   (c), a
    
;    ld    a, #80
;    ld    b, high DMASADDRH
;    out   (c), a
;    ld    b, high DMADADDRH
;    out   (c), a
    
;    ld    hl, copy_text
;    call  set_ports
    
;    jr    skip_switch
    
;skip_switch
;    pop   hl    
    ld    (scr_pos), hl
    halt
    
    jp    loop    
   

int_start
    ; we need to preserve ALL regs because of player routine 
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
    di
    
    ld    a, #40
    ld    bc, VPAGE
    out   (c), a
    
    ld    hl, (scr_pos)
    
    ld    a, h
    ld    b, high GYOFFSH
    out   (c), a
    
    ld    a, l
    ld    b, high GYOFFSL
    out   (c), a
    
    
    ; set int split position
    ld    a, #1
    ld    b, high VSINTH
    out   (c), a
    ld    a, #1F
    ld    b, high VSINTL
    out   (c), a
    
    ld    hl, int_split
    ld    (#6EFF), hl
    
    ; set poll
    xor   a
    ld    (int_poll), a
    
;    ld    a, #E0
;    ld    bc, PAGE3
;    out   (c), a
;    call  #C005
;    
;    ld    a, #40
;    ld    bc, PAGE3
;    out   (c), a
;    
;    ld    bc, #FFFD
;    ld    a, 9
;    out   (c), a
;    in    a, (c)
;    and   #10
;    jr    nz, beat_skip
;    in    a, (c)
;    
;    cp    15
;    jr    nz, beat_skip
;    ld    a, #FA
;    ld    bc, BORDER
;    out   (c), a
;    jr    isr_end
;    
;beat_skip    
;    ld    a, #F0
;    ld    bc, BORDER
;    out   (c), a
;isr_end
    
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
  
int_split
    push  af
    push  bc
    
    ld    a, #42
    ld    bc, VPAGE
    out   (c), a
    
    xor   a
    ld    b, high GYOFFSH
    out   (c), a
    ld    b, high GYOFFSL
    out   (c), a
    
    ; set int start position
    xor   a
    ld    b, high VSINTH
    out   (c), a
    ld    b, high VSINTL
    out   (c), a
    
    ld    bc, int_start
    ld    (#6EFF), bc
    
    pop   bc
    pop   af
    ei
    ret    
   
; text unpacker
unpack
    ld    hl, #8000
    ld    de, #C000
    ld    c,  #07     

str_loop
    ld    a, (hl)
    cp    #0D         ; перевод строки
    jr    z, str_end
    cp    #1C         ; цвет текста
    jr    z, set_color
    ldi               ; иначе тупо ldi
    inc   c           ; восстанавливаем C после ldi
    ld    a, c
    set   7, e
    ld    (de), a     ; херачим атрибут в память
    res   7, e
    jr    str_loop
str_end
    inc   hl
    inc   hl
    inc   d
    jr    nz, current_page
    ; в случае врапа - переходим на следующую пагу
    ld    a, (unpack_page)
    inc   a
    ld    bc, PAGE3
    out   (c), a
    ld    d, #C0
current_page
    ld    e, 0
    ld    a, (hl)
    inc   a
    jp    nz, str_loop
    
    ; в самом конце хотелось бы узнать количество строк
    ld    hl, de
    ld    a, (start_page)
    ld    d, a
    ld    a, (unpack_page)
    sbc   d
    rla
    ld    l, a 
   
    ld    a, h
    and   #3F  
    rla
    rla
    rla
    ld    e, a
    
    ld    a, l
    adc   0
    ld    d, a
    
    ; итого в DE количество строк
    ld    (lines_count), de
    
    ret

set_color
    inc   hl
    ld    c, (hl)
    inc   hl
    jr    str_loop
    
start_page   db #60
unpack_page  db #60
num_pages    db #0

   
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
            
copy_font
        db #1a,0    ;
        db #1b,0	;
        db #1c,#51
        db #1d,0
		db #1e,0	;
        db #1f,#41  

		db #28,3	;
		db #26,#FF	;
		db #27,DMA_RAM
		db #ff
            
            
fill_screen;
		db #1b,0	;
		db #1e,0	;

		db #28,#FF	;
		db #26,#3F	;
		db #27,DMA_FILL | DMA_SALGN | DMA_DALGN
		db #ff

copy_text       db #1a,0	;
                db #1d,0	;
                db #1f,#40	;

                db #28,#F	;
                db #26,#FF	;
                db #27,DMA_RAM
                db #ff
                

k_hold          db  0
k_inc           db  0
k_dir           db  0

int_poll        db  #FF
scr_pos         dw  0

lines_count     dw  0
               
c_end               
 
        savebin "shell.$c", start, (c_end - start)