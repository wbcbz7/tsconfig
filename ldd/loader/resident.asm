    device zxspectrum128
    include "tsconfig.asm"
    
    org #C000
start
    di
    ld   sp, #FFFF        
; желающие вернуться сюда части должны вначале
; замапить эту страницу, поставить стек на #FFFD
; и сделать RET (обязательно с вырубленными интами!!!1!)        
    ; example
    ; part one - tunnel ;)
    
    ;ld   a, #80     ; 1st codeblock
    ;ld   bc, PAGE1 
    ;out  (c), a
    
    ;ld   a, #81     ; 2nd codeblock
    ;ld   bc, PAGE2 
    ;out  (c), a
    
    ;call #6000
    ;ld   sp, #FFFF    
    
    ; part 1 - first twirl (a'la bump :)
    
    ld   a, #C0     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    ld   a, #C1     ; 2nd codeblock
    ld   bc, PAGE2 
    out  (c), a
    
    call #6000
    ld   sp, #FFFF 
    
    ; part 2 - second twirl + prodname
    
    ld   a, #C2     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    ld   a, #C3     ; 2nd codeblock
    ld   bc, PAGE2 
    out  (c), a
    
    call #6000
    ld   sp, #FFFF 
    
    ; part 3 - 3dstuff2
    
    ld   a, #C4     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    call #4000
    ld   sp, #FFFF 
    
    ; part 4 - 3rd twirl + prodname
    
    ld   a, #C6     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    ld   a, #C7     ; 2nd codeblock
    ld   bc, PAGE2 
    out  (c), a
    
    call #6000
    ld   sp, #FFFF 
    
    ; part 5 - 3dstuff3
    
    ld   a, #C8     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    call #4000
    ld   sp, #FFFF 
    
    ; part 6 - "fhofr" in tiles :)
    
    ld   a, #CA     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    call #4000
    ld   sp, #FFFF 
    
    ; part 7 - 4th twirl
    
    ld   a, #CC     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    ld   a, #CD     ; 2nd codeblock
    ld   bc, PAGE2 
    out  (c), a
    
    call #6000
    ld   sp, #FFFF 
    
    ; part 8 - 5th twirl
    
    ld   a, #CE     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    ld   a, #CF     ; 2nd codeblock
    ld   bc, PAGE2 
    out  (c), a
    
    call #6000
    ld   sp, #FFFF 
    
    ; part 9 - 3dstuff
    
    ld   a, #B0     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    call #4000
    ld   sp, #FFFF 
    
    ; part 10 - end
    
    ld   a, #B2     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    call #4000
    ld   sp, #FFFF
    
end
   
   savebin  "resident.$C", start, (end - start)