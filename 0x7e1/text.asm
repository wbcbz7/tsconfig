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
    db " �����ࣣ���... ��३��� �� ���᪨� :)", 13, 10
    db 13, 10
    db " �室�騩 ��� �� ����� �� ����� �", 13, 10
    db "    �祭� ᮡ��� - ����⠡�� ���,", 13, 10
    db "  �⬥��� ५���, 訪��� ����(!),", 13, 10
    db " � � � �� �६� �த�������� ��� �", 13, 10
    db "         ��᪮���� 宫�����. ", 13, 10
    db 13, 10
    db " � � �� �६�, ���⭮ �ᮧ������, ��", 13, 10
    db "  ��� �業� ��㪫���� �������� ���।,", 13, 10
    db " � �� �������� 㦥 ���� �� ��⠭����.", 13, 10

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
    db "  � � ��� ������ ���� � ��� ��������", 13, 10
    db "  �ᥬ ���� ����� � ������� �௥���,", 13, 10
    db "  ������, �����প�, ��, ���஢��.", 13, 10
    db 13, 10
    db "      � ���, ����ࠬ, �㧠��ࠬ,", 13, 10
    db " gfx-�ࠬ, �࣠�����ଠ� ��⥩ - �⮡� ", 13, 10
    db " ������ ������� �� ���������, �⮡� ����", 13, 10
    db "�ᥣ�� ��室��� ��� ��஭��, �⮡� ����", 13, 10
    db "��� �� ᬮ� ������� ��� ᯮ����⢨� =)", 13, 10
    db "  � ������� - �⮡� �த ��� � ���! :) ", 13, 10
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
    db "hypr.ru  - ᯠᨡ� �� �����প�!", 13, 10
    db "tbk4d    - ��� �� ��� �த�? :)", 13, 10
    db "kowalski - ᠭ�, �� ���� rulez, ���!", 13, 10
    db "not-soft - ����� ���� ZaRulem!", 13, 10
    db "grachev  - ����, �� ��ᠩ sibcrew, �� �", 13, 10
    db "           墠�� �� �६� �������� :)", 13, 10
    db "trefi    - �ਥ���� � ����ᨡ! %)", 13, 10
    db "VBI      - �� ������ � ��� ���� �����!", 13, 10
    db "breeze   - ��୨��! =)", 13, 10
    db "TS-Labs  - �����뢠� AYX, ��⥫쭮", 13, 10
    db "           ��� ���㯠�� � ��業��� %)", 13, 10
    
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
    db "spke     - ��� �ᥣ�� �ᯥ客!", 13, 10
    db "g0blin   - ����� ���� - ����� 䠭�!", 13, 10
    db "tmk      - break dat border! :)", 13, 10
    db "sq       - ��� �� � ��, �� �������", 13, 10
    db "tayle    - �� ������� �� �祡� :D", 13, 10
    db "nyuk     - ����� ����� ���⨬�⮣��!", 13, 10
    db "nodeus   - ᯠᨡ� �� ������ � ��䮭��!", 13, 10
    db "muzakers - �� ���� �������, �㧮�� -", 13, 10
    db "           R U L E Z   F O R E V E R !", 13, 10
    db "  � ����� ���� ����⭨� �⠢��� ����!", 13, 10
    db "----------------------------------------", 13, 10
    db "           ���ᨡ� ��� �� ��!", 13, 10
    
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
    db " �� �� ��㣨� � �� ���� - ��� �ਢ���:", 13, 10
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
    db "  ER - destr (��ন��!) - aturbidflow", 13, 10
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
    db "            ��筥� ������! :)", 13, 10
    db 27 ; clear
    
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 13, 10
    
    db 255 ; end

end

    savebin "text.txt", start, end-start