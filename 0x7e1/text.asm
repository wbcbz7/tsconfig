       ;                                          *
    device zxspectrum128
    org 0
    
start

    db 13, 10
    db 13, 10
    db "                 Hola!", 13, 10
    db 13, 10
    db "   wbc\\b-state is proud to wish you a", 13, 10
    db "           happy new 2017 year!", 13, 10
    db 13, 10
    db "   so, I decided to grab some time and", 13, 10
    db "    unreleased sources and build this", 13, 10
    db "     small but anyway nice intro =)", 13, 10

    db 127, 27 ; delay + clear    

    dup 10
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    edup     

    db 27 ; clear
    db 13, 10
    db " эээррргггхх... перейдем на русский :)", 13, 10
    db 13, 10
    db " Уходящий год был богат на приятные и", 13, 10
    db "    очень события - масштабные пати,", 13, 10
    db "  отменные релизы, шикарные ДЕМЫ(!),", 13, 10
    db " и в то же время продолжались срачи и", 13, 10
    db "         бесконечные холивары. ", 13, 10
    db 13, 10
    db " В то же время, приятно осознавать, что", 13, 10
    db "  наша сцена неуклонно движется вперед,", 13, 10
    db " и это движение уже никто не остановит.", 13, 10

    db 127, 27 ; delay + clear
    
    dup 12
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    edup   
    
       ;                                          *
    db 27 ; clear
    db "  И в этот зимний день я хочу пожелать", 13, 10
    db "  всем моим друзьям и близким терпения,", 13, 10
    db "  заботы, поддержки, любви, здоровья.", 13, 10
    db 13, 10
    db "      А нам, кодерам, музакерам,", 13, 10
    db " gfx-ерам, организатормам патей - чтобы ", 13, 10
    db " железо никогда не подводило, чтобы баги", 13, 10
    db "всегда обходили вас стороной, чтобы злой", 13, 10
    db "ААА не смог нарушить ваше спокойствие =)", 13, 10
    db "  а главное - чтобы прод БЫЛ и ПЕР! :) ", 13, 10
    db "                                         ",13, 10
    db "        HAPPY NEW 0x7e1, SCENE!", 13, 10
    
    db 127, 27 ; delay + clear
    
    dup 12
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    edup  
    
       ;                                        *
    db 27 ; clear
    db "----------------------------------------", 13, 10
    db "    messages to all my scene friends:", 13, 10
    db "hypr.ru  - спасибо за поддержку!", 13, 10
    db "tbk4d    - где же ваши проды? :)", 13, 10
    db "kowalski - саня, ты просто rulez, жги!", 13, 10
    db "not-soft - даешь новый ZaRulem!", 13, 10
    db "grachev  - деня, не бросай sibcrew, да и", 13, 10
    db "           хватит все время прятаться :)", 13, 10
    db "trefi    - приезжай в Новосиб! %)", 13, 10
    db "VBI      - не ленись и пиши демы дальше!", 13, 10
    db "breeze   - вернись! =)", 13, 10
    db "TS-Labs  - доделывай AYX, решительно", 13, 10
    db "           хочу пощупать и заценить %)", 13, 10
    
    db 127, 27 ; delay + clear
    
    dup 13
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    edup  
    
       ;                                        *
    db 27 ; clear
    db "----------------------------------------", 13, 10
    db "spke     - как всегда успехов!", 13, 10
    db "g0blin   - больше стаффа - больше фана!", 13, 10
    db "tmk      - break dat border! :)", 13, 10
    db "sq       - хоть ты и злюка, но молодец", 13, 10
    db "tayle    - не забивай на учебу :D", 13, 10
    db "nyuk     - даешь больше Мультиматографа!", 13, 10
    db "nodeus   - спасибо за помощь с графоном!", 13, 10
    db "muzakers - вы просто монстры, музоны -", 13, 10
    db "           R U L E Z   F O R E V E R !", 13, 10
    db "  а Олеже просто памятник ставить надо!", 13, 10
    db "----------------------------------------", 13, 10
    db "           Спасибо вам за все!", 13, 10
    
    db 127, 27 ; delay + clear
    
    dup 13
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    edup 
    
       ;                                        *
    db 27 ; clear
    db 13, 10
    db " но про других я не забыл - вот приветы:", 13, 10
    db "----------------------------------------", 13, 10
    db " triebkraft - 4th dimension - thesuper", 13, 10
    db "  demarche - sibCrew - kpacku - skrju", 13, 10
    db " tekkkkno_lab - consciousness - gemba", 13, 10
    db "  not-soft - desire - mercury - rift", 13, 10
    db "  ivorylabs - (b)yterapers - fishbone", 13, 10
    db "    lifeonmars - zeroteam - h-prg", 13, 10
    db "----------------------------------------", 13, 10

    db 127, 27 ; delay + clear
    
    dup 10
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    edup 
    
       ;                                        *
    db 27 ; clear
    db 13, 10
    db "         and personal greetings:", 13, 10
    db "----------------------------------------", 13, 10
    db " diver4d - psndcj - prof4d - introspec", 13, 10
    db " sq - tmk - kowalski - vbi - g0blinish", 13, 10
    db "c-jeff - fatal snipe - mmcm - quiet - nq", 13, 10
    db "  scalesmann - kakos_nonos - amixgris", 13, 10
    db "   TS-Labs - breeze - koshi - grachev", 13, 10
    db "   blastoff - denpopov - nyuk - tayle", 13, 10
    db "   factor6 - riskej - tiboh - trefi", 13, 10
    db "----------------------------------------", 13, 10
    
    db 127, 27 ; delay + clear
    
    dup 11
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    edup 
    
    db 27 ; clear
    db 13, 10
    db "----------------------------------------", 13, 10
    db " djoni - kas29 - buddy - random - robus", 13, 10
    db "evovxn - pertsovsky - olegorigin - r0bat", 13, 10
    db "  ER - destr (держись!) - aturbidflow", 13, 10
    db " sensenstahl - hellmood - baudsurfer(!) ", 13, 10
    db " branch - mikron - roz - optimus - visy ", 13, 10
    db " orby - scali - jmph - las - cupe - po1 ", 13, 10
    db "----------------------------------------", 13, 10
    db "                and YOU!", 13, 10
    
    db 127, 27 ; delay + clear
    
    dup 12
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    edup 
    
       ;                                        *
    db 27 ; clear
    db 13, 10
    db 13, 10
    db "                credits:", 13, 10
    db "----------------------------------------", 13, 10
    db "dirty 3 hours code................wbcbz7", 13, 10
    db "8x8 font...........................r0bat", 13, 10
    db "music...dualtrax -> the travel to orion!", 13, 10
    db "pt3 cover.........................wbcbz7", 13, 10
    db "----------------------------------------", 13, 10
    db "                                        ", 13, 10
    db "        b-state 31.12.2016 23:29", 13, 10
    
    db 127, 27 ; delay + clear
    
    dup 11
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    edup 
    
    db 27 ; clear
    db "            начнем заново! :)", 13, 10
    db 27 ; clear
    
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    
    db 255 ; end

end

    savebin "text.txt", start, end-start