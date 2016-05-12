    device zxspectrum128
    include "tsconfig.asm"
    
music_page     equ   #E0
resident_page  equ   #E1
    
    org  #8000              ; standard running address
start
    di
    ld    sp, #BFFF
    call  zap_trash
    call  make_noize
    call  zap_trash
    
    ; init resident part and music player
    
    ld    bc, PAGE3
    ld    a, music_page
    out   (c), a
    
    call  #C000              ; INIT
    
    ld    a, VID_NOGFX
    ld    bc, VCONFIG
    out   (c), a
    
    ei
loop
    halt
    call  #C005              ; PLAY
    
    ld    a, (downcount)
    dec   a
    ld    (downcount), a
    jr    nz, loop
    
    ld    bc, PAGE3
    ld    a, resident_page
    out   (c), a
    
    jp    #C000
    
downcount db 192
    
    
zap_trash
    ; и снова зпiзженно :)
    ld    bc, VCONFIG
    ld    a, %00110000
    out   (c), a
    
    ld b, high FMADDR
    ld a, FM_EN
    out (c), a      ; open FPGA arrays at #0000
   
    ; clean SFILE
    ld hl, FM_SFILE
    xor a
l1  ld (hl), a
    inc l
    jr nz, l1
    inc h
l2  ld (hl), a
    inc l
    jr nz, l2
   
    out (c), a      ; close FPGA arrays at #0000
   
   ; zeroing scrollers to avoid surprises from previous usage
   ld b, high GXOFFSL : out (c), a
   ld b, high GXOFFSH : out (c), a
   ld b, high GYOFFSL : out (c), a
   ld b, high GYOFFSH : out (c), a
   ld b, high T0XOFFSL : out (c), a
   ld b, high T0XOFFSH : out (c), a
   ld b, high T0YOFFSL : out (c), a
   ld b, high T0YOFFSH : out (c), a
   ld b, high T1XOFFSL : out (c), a
   ld b, high T1XOFFSH : out (c), a
   ld b, high T1YOFFSL : out (c), a
   ld b, high T1YOFFSH : out (c), a
   ld b, high BORDER : out (c), a
   ld b, high TSCONFIG : out (c), a
   ld b, high VCONFIG : out (c), a
   
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
    and  #1F
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
    or   #F0
    ld   b,  high BORDER
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
 
end
   
   savebin  "loader.$C", start, (end - start)