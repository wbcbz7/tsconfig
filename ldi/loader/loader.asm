    device zxspectrum128
    include "tsconfig.asm"
    
music_page     equ   #E0
resident_page  equ   #E1
    
    org  #8000              ; standard running address
start
    di
    ld    sp, #BFFF
    call  zap_trash
    
    ; init resident part and music player
    
    ld    bc, PAGE3
    ld    a, music_page
    out   (c), a
    
    call  #C000              ; INIT
    
    ld    bc, PAGE3
    ld    a, resident_page
    out   (c), a
    
    jp    #C000
    
;    ei
;loop
;    halt
;    call  #C005              ; PLAY
;    jr    loop
    
    
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
   
   ret

end
   
   savebin  "loader.$C", start, (end - start)