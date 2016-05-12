

    device zxspectrum128
    include "tsconfig.asm"

    ;define standalone
    
    ifndef  standalone
mainpage    equ #B2
    endif
    ifdef  standalone
mainpage    equ #5
    endif
    
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
    
    
    ld    hl,pals
    call  set_ports
    call  dma_stats
    
    ld    a, 0
    ld    bc, PALSEL
    out   (c),a
    
    ld    b, high GXOFFSL
    out   (c),a
   
    ld    a, #40
    ld    b, high VPAGE
    out   (c),a
    ld    b, high PAGE3
    out   (c),a    
    
    ld    a, 0
    ld    bc,GYOFFSL
    out   (c),a

    ld    a, 0
    ld    b, high GYOFFSH
    out   (c),a        
    
    ld    a,%00000001
    ld    bc,VCONFIG
    out   (c), a
    ld    a,%00000110  ; 14 MHz + cache
    ld    bc,SYSCONFIG 
    out   (c), a    
    
    call  dma_stats
    ld    hl, copy_pic
    call  set_ports
    
    ei
    ld    bc, 0
outer
    halt
    
    ; тут какая-то магия с fade-in и чередованием строк для интерлейса    
    ld    a, (FadeInTimeout)
    ld    d, a
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
   
    ; check for hidden part keypress
    ; F
    ld    a, #FD
    in    a, (#FE)
    and   #8
    jp    nz, fail
    
    ; U
    ld    a, #DF
    in    a, (#FE)
    and   #8
    jp    nz, fail
    
    ; C
    ld    a, #FE
    in    a, (#FE)
    and   #8
    jp    nz, fail

    ; K
    ld    a, #BF
    in    a, (#FE)
    and   #4
    jp    nz, fail
    
    jr    hidden_part
    
fail
    ; check for another hidden part
    
    ; L
    ld    a, #BF
    in    a, (#FE)
    and   #2
    jp    nz, outer
    
    ; V
    ld    a, #FE
    in    a, (#FE)
    and   #10
    jp    nz, outer
    
    ; D
    ld    a, #FD
    in    a, (#FE)
    and   #4
    jp    nz, outer
    
    jr    lvd_pidor

    
hidden_part
    ld    a, VID_320X200 | VID_256C
    ld    bc, VCONFIG
    out   (c), a
    
    ld    a, #40
    ld    b, high VPAGE
    out   (c), a
    
    ld    hl,phuk_pals
    call  set_ports
    call  dma_stats
    
    ld    hl,phuk_pic
    call  set_ports
    call  dma_stats

    di
    halt
    
lvd_pidor
    ld    a, VID_256X192 | VID_16C
    ld    bc, VCONFIG
    out   (c), a
    
    ld    a, #40
    ld    b, high VPAGE
    out   (c), a
    
    xor   a
    ld    b, high PALSEL
    out   (c), a
    
    ld    hl,lvd_pals
    call  set_ports
    call  dma_stats
    
    ld    hl,lvd_pic
    call  set_ports
    call  dma_stats

    di
    halt
    
int_handler
    push  af
    push  bc
    push  de
    push  hl
    
    ld    a, (BeatCounter)
    dec   a
    ld    (BeatCounter), a
    jr    nz, isr_bskip
    ld    a, 13
    ld    (FadeInTimeout), a
    ld    a, 0
    ld    (nofadein), a
    ld    a, 24
    ld    (BeatCounter), a
isr_bskip

    exx
    ex    af, af' ;'
    push  af
    push  bc
    push  de
    push  hl
    exx
    ex    af, af' ;'
    ;----------------------
    
    ifndef standalone
    ld    a, #E0
    ld    bc, PAGE3
    out   (c), a
    call  #C005
    endif
    
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
		db #1c, mainpage
	        db #1d, 0
	        db #1e, 0
	        db #1f, 0
	        db #26, #FF
	        db #28, 0
	        db #27, DMA_RAM_CRAM     ; #84 - копирование из RAM в CRAM
		db #ff  
            
phuk_pals
		db #1a, #0
	    db #1b, 0
		db #1c, #B4
	    db #1d, 0
	    db #1e, 0
	    db #1f, 0
	    db #26, #FF
	    db #28, 0
	    db #27, DMA_RAM_CRAM     ; #84 - копирование из RAM в CRAM
		db #ff  
        
phuk_pic
	    db #1a, 0	;
        db #1b, 0
		db #1c, #98	;
        db #1d, 0
		db #1e, 0	;
		db #1f, #40	;

		db #28, 199	;
		db #26, 159	;
		db #27, DMA_RAM | DMA_DALGN | DMA_ASZ
		db #ff 
        
lvd_pals
		db #1a, #0
	    db #1b, 0
		db #1c, #B5
	    db #1d, 0
	    db #1e, 0
	    db #1f, 0
	    db #26, #FF
	    db #28, 0
	    db #27, DMA_RAM_CRAM     ; #84 - копирование из RAM в CRAM
		db #ff  
        
lvd_pic
	    db #1a, 0	;
        db #1b, 0
		db #1c, #9C	;
        db #1d, 0
		db #1e, 0	;
		db #1f, #40	;

		db #28, 191	;
		db #26, 63	;
		db #27, DMA_RAM | DMA_DALGN
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
                
copy_pic	db #1a, 0	;
                db #1b, 0
		db #1c, #B8	;
                db #1d, 0
		db #1e, 0	;
		db #1f, #40	;

		db #28, 191	;
		db #26, 63	;
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

    
    savebin "end.$c", #4000, #800
;    savesna "tunnel.sna", start