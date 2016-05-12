    device zxspectrum128
    include "tsconfig.asm"
    
    org #C000
start
    di
    ld   sp, #FFFF        
; желающие вернуться сюда части должны вначале
; замапить эту страницу, поставить стек на #FFFD
; и сделать RET (обязательно с вырубленными интами!!!1!)        
    
    ; part one - tunnel ;)
    
    ld   a, #80     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    ld   a, #81     ; 2nd codeblock
    ld   bc, PAGE2 
    out  (c), a
    
    call #6000
    ld   sp, #FFFF
    
    ; part two - metaballs
    
    ld   a, #82     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    call #4000
    ld   sp, #FFFF
    
    ; part three - first twirl ;)
    
    ld   a, #83     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    ld   a, #84     ; 2nd codeblock
    ld   bc, PAGE2 
    out  (c), a
    
    call #6000
    ld   sp, #FFFF
    
    ; part four - 3d stuff
    
    ld   a, #85     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    ;ld   a, #84     ; 2nd codeblock
    ;ld   bc, PAGE2 
    ;out  (c), a
    
    call #4000
    ld   sp, #FFFF
    
    ; part five - second twirl 
    
    ld   a, #86     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    ld   a, #87     ; 2nd codeblock
    ld   bc, PAGE2 
    out  (c), a
    
    call #6000
    ld   sp, #FFFF
    
    ; part six - the end (ну наконеееец-то! :) 
    
    ld   a, #88     ; 1st codeblock
    ld   bc, PAGE1 
    out  (c), a
    
    call #4000
    
end
   
   savebin  "resident.$C", start, (end - start)