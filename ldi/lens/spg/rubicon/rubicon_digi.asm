	device zxspectrum128


lines_color_db	equ #7000
sins		equ #7000
tm_count_db	equ #7d00
font_db		equ #7c00
rubicon_bottom_sin	equ font_db
Vid_page	equ #80
Tile_page	equ #38
Tiles_tun_page	equ #40	; #40-#68

Tile0_spr_page	equ #a0
Tile1_spr_page	equ #a8
rubik_spr_page	equ #b0
SFileAddr       EQU 512
Font_spr_page	equ #c0
kali1_spr_page	equ Font_spr_page+8
kali2_spr_page	equ kali1_spr_page+8
kali1_spr_part_page	equ kali2_spr_page+16
kali2_spr_part_page	equ kali1_spr_part_page+16


kali1_page	equ 38
kali1_pal_page	equ 45
kali2_page	equ 46
kali2_pal_page	equ 49


twister_page	equ 32
tunnel_page	equ #10
mus_page	equ 25
music		equ #c000
rubik_page	equ 26	
wave_page	equ 26
lines_page	equ 27	;-30
rubikon_logo_page	equ 31
rubikon_pal_page	equ 26	; #f600
rubicon_sinus_page	equ 26	; #f800
rubicon_sinus		equ #fa00
rubic_bottom_pal	equ #d200 	;24
rubic_bottom_page	equ 31	; #e000

font_page	equ 36	;font_pal	equ #c400	; 37
hello_adr	equ #c600

julia_page	equ 35

sync_wait2	equ #180/2
sync_wait4	equ #180/4

		org #8000
start

		di
		ld hl,%01001010*256
		ld sp,#7fff
		call clr_screen
		call spr_off
		call im2_init
		ld bc,PAGE3
		ld a,mus_page
		out (c),a
		ld hl,#c011
		ld de,#c000
		ld bc,#3000
		ldir
		call music
		ld hl,kali1_copy
		call set_ports
		ld b,#27
		ld a,%00010001
		out (c),a
		call dma_stats
		ld hl,kali2_copy
		call set_ports
		ld b,#27
		ld a,%00010001
		out (c),a
		call dma_stats


		ld hl,font_copy
		call set_ports


; tunnel background copy
		ld bc,#1aaf
		xor a
		out (c),a
		inc b
		out (c),a
		inc b
		ld a,#10
		out (c),a

		ld de,#4010	; #40 - tile_gfx temp
		ld b,8
tilpage1	push bc
		ld bc,#1daf
		xor a
		out (c),a
		inc b
		out (c),a
		inc b
		out (c),d
		ld a,d
		add 8
		ld d,a
		ld b,#26
		ld a,80-1
		out (c),a
		ld b,#28
		ld a,136
		out (c),a
		dec b
		ld a,%00010001
		out (c),a
		call dma_stats
		pop bc
		djnz tilpage1


		ld hl,lines_color_db
		ld de,lines_color_db+1
		ld (hl),l
		ld bc,#1ff
		ldir
		ld de,rubicon_bottom_sin
		ld bc,#7708  	;b:начало, с: размах   с меньше b!!!
		call SINMAKE

		ld hl,lines
		call set_ports
		ld hl,rubikon_logo_ports
		call set_ports
		ld hl,rubikon_bottom_ports
		call set_ports
		ld hl,rubikon_bottom_pal
		call set_ports

		call clear_tileset

		ld hl,#e300
		ld de,#1000
		ld bc,#2806
rbfil1		push bc
rbfil2		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		inc de
		djnz rbfil2
		ld bc,#100-#28*2
		add hl,bc
		ex de,hl
		ld bc,#40-#28
		add hl,bc
		ex de,hl
		pop bc
		dec c
		jr nz,rbfil1

		ld bc,VCONFIG
		ld a,%01000010
		out (c),a
		ld b,#0f
		ld a,#20
		out (c),a
		ld b,7
		xor a
		out (c),a
		ld bc,T0GPAGE
		ld a,Tile0_spr_page
		out (c),a
		ld b,6
		ld a,%10100100	; spr,T0 enable
		out (c),a
		ld bc,SGPAGE
		ld a,rubik_spr_page
		out (c),a

		ld bc,TMPAGE
		ld a,Tile_page
		out (c),a
		ld hl,lines_pal
		call set_ports
		ld hl,rubikon_logo_pal
		call set_ports
		ld	bc,MEMCONFIG
		ld	a,%00001110
		out	(c),a
		ld bc,PAGE0
		ld a,50
		out (c),a



rub_bot_t0	ld a,0
		ld bc,T0YOFFSL
		out (c),a
		ei

;		jp Tunnel_part
;		jp tun_check_fin

wait_counter	ld hl,#180
		dec hl
		ld (wait_counter+1),hl
		halt
		ld a,(rub_bot_t0+1)
		inc a
		cp #80
		jr z,$+7
		ld (rub_bot_t0+1),a
		out (c),a
		ld a,h
		or l
		jr nz,wait_counter

lines_loop
		ld hl,lines_pal
		call set_ports
		ld a,(lines_counter+2)
		cp 4
		jr nc,rubicon_spr_view
rubicon_bsin	ld hl,rubicon_bottom_sin+#4f
		inc l
		ld (rubicon_bsin+1),hl
		ld a,(hl)
		ld bc,T0YOFFSL
		out (c),a

rubicon_spr_view
		ld a,0
		or a
		jr z,rubicon_spr_view_ex
		call rubicon_logo_pos
		ld hl,rubikon_logo_spr
		call set_ports

rubicon_spr_on	ld a,0
		inc a
		and #3f
		ld (rubicon_spr_on+1),a
		jr nz,rubicon_spr_on_ex

rubicon_spr_on_cnt
		ld a,8
		dec a
		jr z,rubicon_spr_on_ex
		ld (rubicon_spr_on_cnt+1),a

rubicon_spr_on_adr
		ld hl,logo_spr+1
		ld de,6
		ld a,(hl)
		or #20
		ld (hl),a
		add hl,de
		ld (rubicon_spr_on_adr+1),hl

rubicon_spr_on_ex
		
rubicon_spr_view_ex

		ld hl,lines_color_db+#ff
		ld de,lines_color_db+#fe

		ld b,#80
		ld a,(de)
		ld (hl),a
		dec hl
		dec de
		ld a,(de)
		ld (hl),a
		dec hl
		dec de
		djnz $-8
		ld hl,(lines_counter+1)
		ld de,#238
		or a
		sbc hl,de
		jr nc,lines_counter
		ld a,1
		ld (rubicon_spr_view+1),a
lines_counter	ld hl,#180*3+#80	; test_wait
		dec hl
		ld a,h
		or l
		jr nz,lines_scroll
lines_counter2	ld hl,#102
		dec hl
		ld (lines_counter2+1),hl
		ld a,h
		or l
		jp z,Kaliskop_part

		xor a
		ld hl,lines_color_db
		ld (hl),a
		inc l
		ld (hl),a
		jr lines_scroll_ex


lines_scroll	ld (lines_counter+1),hl
		ld de,lines_color_db
lines_scroll2	ld hl,lines_colors
		ld a,(hl)
		cp #ff
		jr nz,lines_scroll1
		ld hl,lines_colors
		ld (lines_scroll2+1),hl
		ld a,(hl)
lines_scroll1	ld (de),a
		inc e
		inc hl
		ld a,(hl)
		ld (de),a
		inc hl
		ld (lines_scroll2+1),hl
lines_scroll_ex

		ei 
		halt
		jp lines_loop



rubicon_logo_pos
		ld bc,PAGE3
		ld a,rubicon_sinus_page
		out (c),a
		ld hl,rubicon_logo_pos_db		
		ld ix,logo_spr
		ld b,7

rubicon_logo_pos1		
		ld e,(hl)
		inc hl
		ld d,(hl)
		dec hl
		inc de
		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		push hl
		ld hl,rubicon_sinus
		add hl,de
rubicon_logo_pos2
		nop
		ld a,(hl)
		pop hl
		ld (ix+0),a
		ld de,6
		add ix,de
		djnz rubicon_logo_pos1
		ret


rubicon_logo_pos_db
		dw 0,10,20,30,40,50,60

Kaliskop_part
		call clear_tileset
		di
		ld hl,#c000
		ld ix,#c050-2
		ld de,0
		call kali_t_fill
		push hl
		ld hl,#c080
		ld ix,#c080+#50-2
		ld de,#1000
		call kali_t_fill

		ld e,c
		ld l,e
		ld d,h
		dec h
		ld a,#10
ktfil3		ld bc,#100
		push hl
		push de
		ldir
		pop de
		pop hl
		dec h
		inc d
		dec a
		jr nz,ktfil3
		pop hl
ktfil4		inc hl
		set 7,(hl)
		inc hl
		ld a,h
		cp #0
		jr nz,ktfil4
		ei
		xor a
		ld bc,T0YOFFSL
		out (c),a

		ld hl,kali1_pal
		call set_ports
		ld hl,kali2_pal
		call set_ports



		ld bc,T0GPAGE
		ld a,kali1_spr_part_page
		out (c),a
		inc b
		ld a,kali2_spr_part_page
		out (c),a
		ld bc,TMPAGE
		ld a,Tile_page
		out (c),a
		ld b,6
		ld a,%00100100	; T1,T0 enable
		out (c),a
		inc b		; palsel
		ld a,0
		out (c),a
		ld b,0
		ld a,%01000010
		out (c),a
		ld bc,PAGE3
		ld a,Vid_page
		out (c),a
		ld hl,#0101
		ld (#c000),hl
		ld b,#f
		out (c),l
		ld hl,screen_init_clr
		call set_ports
		ld de,rubicon_bottom_sin
		ld bc,#201f
		call SINMAKE
		di
		ld	bc,INTMASK
		ld	a,%00000011
		out	(c),a
		ld	hl,line_proc
		ld	(#befd),hl
		ei


Kaliskop_loop

wait_counter2	ld a,0
		or a
		jr z,wait_counter2
		xor a
		ld (wait_counter2+1),a
line_wait_cnt	ld a,0
		inc a
		cp 48
		jr nz,line_wait_cnt1
/*
		ld bc,PAGE0
wav_page_0	ld a,50
		xor 1
		ld (wav_page_0+1),a
		out (c),a
*/
		xor a
		ld hl,0-320
		ld (digi_pos+1),hl
line_wait_cnt1	ld (line_wait_cnt+1),a
digi_pos	ld hl,0-320
		ld de,320
		add hl,de
		ld (digi_pos+1),hl
		ld (wav_pos+1),hl



kali0_sin	ld hl,sinsin
		inc l
		ld (kali0_sin+1),hl


		ld c,kali1_spr_page
		ld a,(hl)
		sub #38
		cp #40
		jr c,kali0_sin2
		inc c
		sub #40
		cp #40
		jr nc,$-5
kali0_sin2	

		ld (kalidoskop_part_copy+3),a
		ld a,c
		ld (kalidoskop_part_copy+5),a

kali_count	ld hl,#180
		dec hl
		ld (kali_count+1),hl
		ld a,h
		or l
		jr nz,Kali_t01
		ld bc,#06af
		ld a,%01101100	; T1,T0 enable
		out (c),a


Kali_t01	ld a,(kalidoskop_part_copy+1)
		inc a
		cp #a0
		jr nz,$+3
		xor a
		ld (kalidoskop_part_copy+1),a

kali1_sin	ld hl,rubicon_bottom_sin
		inc l
		ld (kali1_sin+1),hl
		ld a,(hl)

		ld (kalidoskop2_part_copy+3),a

		ld a,(kalidoskop2_part_copy+1)
		inc a
		cp 320/4
		jr nz,$+3
		xor a
		ld (kalidoskop2_part_copy+1),a

		ld hl,kalidoskop_part_copy
		call set_ports
		ld hl,kalidoskop2_part_copy
		call set_ports


two_counter	ld hl,#180*2+#180	; test_wait
		dec hl
		ld (two_counter+1),hl
		ld a,h
		or l
		jr nz,Kaliskop_halt
		jp Twister_part

Kaliskop_halt	ld de,#20
		or a
		sbc hl,de
		jp nz,Kaliskop_loop

		ld	bc,INTMASK
		ld	a,%00000001
		out	(c),a

;		halt
		jp Kaliskop_loop

kali_t_fill
		ld bc,#140d
ktfil1		push bc
		push hl
		push ix
ktfil2		ld (hl),e
		ld (ix+0),e
		inc hl
		ld (hl),d
		ld a,d
		set 6,a
		ld (ix+1),a
		dec ix
		dec ix
		inc hl
		inc de
		djnz ktfil2
		pop ix
		inc ixh
		pop hl
		inc h
		ex de,hl
		ld bc,#40-#14
		add hl,bc
		ex de,hl
		pop bc
		dec c
		jr nz,ktfil1
		ret



Tunnel_part	call clr_screen
		call spr_off
		ld de,sins+#100
		ld bc,#403f
		call SINMAKE
		ld hl,sin_tunnel
		ld de,sins
		ld b,0
		ld a,(hl)
		add #100-#f8
		ld (de),a
		inc hl
		inc de
		djnz $-6
		call tunnel_init
		call wave_init

		ld hl,rubik_tset_copy
		call set_ports
		ld hl,rubik_pal_init
		call set_ports

		ld bc,T0GPAGE
		ld a,Tile0_spr_page
		out (c),a
		inc b
		ld a,Tile1_spr_page
		out (c),a
		inc b
		ld a,rubik_spr_page
		out (c),a
		ld bc,TMPAGE
		ld a,Tile_page
		out (c),a
		ld b,6
		ld a,%10100100	; spr,T0 enable
		out (c),a

		inc b		; palsel
		xor a
		out (c),a
		ld bc,T0YOFFSL
		out (c),a
		ld b,0
		ld a,%10100001
		out (c),a
		ld hl,(timecount+1)
		ld	bc,INTMASK
		ld	a,%00000011
		out	(c),a
	
		ld	hl,line_proc
		ld	(#befd),hl
		ld bc,PAGE0
		ld a,51
		out (c),a


		ei




loop
tline_wait_cnt	ld a,0
		inc a
		cp 48
		jr nz,tline_wait_cnt1

		xor a
		ld hl,0-320
		ld (tdigi_pos+1),hl
tline_wait_cnt1	ld (tline_wait_cnt+1),a
tdigi_pos	ld hl,0-320
		ld de,320
		add hl,de
		ld (tdigi_pos+1),hl
		ld (wav_pos+1),hl

tloop		ld a,2
		dec a
		and #0f
		ld (tloop+1),a
		jp nz,tun_eff

;		#ac - end patterns
; 		#88 - finish him!

tun_check_cnt	ld a,0	; #e8	;10*#180 - #80	
		dec a
		ld (tun_check_cnt+1),a
		cp #f4
		jr nc,flash_tun_check
		ld (flash_check+1),a
flash_tun_check	cp #ec				; #e8-18
		jr nc,tun_rubik_check
		ld (tunnel_updown_swith+1),a
tun_rubik_check	cp #d0
		jr nc,tun_wave_check
		ld (spr_out_swith+1),a
tun_wave_check	cp #b8
		jr nc,tun_check_ex
		push af
		ld bc,TSCONFIG
		ld a,%11100100	; spr,T1,T0 enable
		out (c),a
		ld (wave_swith+1),a
		ld	bc,INTMASK
		ld	a,%00000001
		out	(c),a
		pop af


tun_check_ex	cp #98
		jr nc,tun_check_ex2
		push af
		ld bc,TSCONFIG
		ld a,%10100100	; spr,T1,T0 enable
		out (c),a
		ld (wave_swith+1),a
		pop af
tun_check_ex2	
		cp #90
		jr nc,tun_check_ex3
		push af
		xor a
		ld (spr_out_swith+1),a
		call spr_off
		pop af

tun_check_ex3	cp #88
		jr nc,tun_eff

tun_check_fin	
		ld hl,#ffff
		ld (clr_screen_clr+1),hl
		call clr_screen
		ld a,%10000001
		ld bc,VCONFIG
		out (c),a
		ld b,#0f
		ld a,#1f
		out (c),a
		ld b,6
		ld a,%10000000	; spr,T0 enable
		out (c),a
		inc b
		ld a,1
		out (c),a

		ld hl,rubikon_logo_ports
		call set_ports
		ld hl,rubikon_logo_pal
		call set_ports
		ld bc,SGPAGE
		ld a,rubik_spr_page
		out (c),a

		ld hl,rubikon_logo_spr
		call set_ports
		ld hl,julia_pal
		call set_ports
		ld hl,julia_bin
		call set_ports

		ld bc,PAGE3
		ld a,mus_page
		out (c),a
		call music
		di
		jr $		; So, cool? ;) Finita la comedia.



tun_eff		ld hl,tunnel_pal_init
		call set_ports


tunnel_cnt	ld a,Tiles_tun_page-8
		add 8
		cp #70
		jr nz,tunnel_cnt2
		ld a,Tiles_tun_page
tunnel_cnt2	ld (tunnel_cnt+1),a
		ld bc,T0GPAGE
		out (c),a

tunnel_updown_swith
		ld a,0
		or a
		jr z,clr_switch5


tun_sin		ld hl,sins+#64
		inc l
		ld (tun_sin+1),hl
		ld a,(hl)
		ld bc,T0YOFFSL
		out (c),a

clr_switch5	ld hl,sins
		ld a,(hl)
		inc l
		ld (wave_adder+1),a
		ld (clr_switch5+1),hl


		ld hl,#0473
clr_switch	ld a,#2e
		inc a
		cp #30
		jr nz,$+3
		xor a
		ld (clr_switch+1),a
		cp 5
		jr nc,flash_check
clr_switch4	ld hl,(clr_switch5+1)
		dec h
		ld a,(hl)
		ld (wave+1),a

clr_switch3	ld hl,0
		inc h
		inc l
		ld (clr_switch3+1),hl

flash_check	ld a,0
		or a
		jr z,spr_out_swith
		ld bc,PAGE3
		ld a,24
		out (c),a
		ld (#d004),hl

spr_out_swith	ld a,0
		or a
		call nz,spr_out
wave_swith	ld a,0
		or a
		call nz,wave

;		halt

wait_counter3	ld a,(wait_counter2+1)
		or a
		jr z,wait_counter3
		xor a
		ld (wait_counter2+1),a
		jp loop

spr_off		ld bc, FMADDR
		ld a, FM_EN
		out (c), a      ; open FPGA arrays at #0000
		; clean SFILE

FM_SFILE        equ #0200
		ld hl,FM_SFILE
		xor a
spr_off_l1	ld (hl), a
		inc l
		jr nz,spr_off_l1
		inc h
spr_off_l2	ld (hl), a
		inc l
		jr nz,spr_off_l2
		out (c), a      ; close FPGA arrays at #0000
		ret
spr_out
		ld hl,(tun_sin+1)
		ld a,(hl)
		add 56
		ld hl,spr1
		ld de,6
		ld (hl),a
		add hl,de
		ld (hl),a
		add hl,de
		add a,64
		ld (hl),a
		add hl,de
		ld (hl),a
		ld hl,(tun_sin+1)
		ld a,l
		add #b0
		ld l,a
		ld a,(hl)
		add 96
		ld hl,spr1+2
		ld de,6
		ld (hl),a
		add hl,de
		add a,64
		ld (hl),a
		add hl,de
		sub 64
		ld (hl),a
		add hl,de
		add a,64
		ld (hl),a

		ld hl,rubik_spr
		jp set_ports

clr_screen	ld bc,PAGE3
		ld a,Vid_page
		out (c),a
		ld b,#0f
clr_screen_clr	ld hl,0
		ld (#c000),hl
		out (c),l
		ld b,0
		ld a,%10110001
		out (c),a
		ld hl,screen_init
		jp set_ports


wave_init
		ld hl,#c0a0
		ld de,#1001
		ld bc,#0820
t1fil1		push bc
t1fil2		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		inc de
		djnz t1fil2
		ld bc,#100-#08*2
		add hl,bc
		ex de,hl
		ld bc,#40-#8
		add hl,bc
		ex de,hl
		pop bc
		dec c
		jr nz,t1fil1

		ld hl,wave_pal_init
		jp set_ports


tunnel_init
		ld hl,tunnel_pal_init
		call set_ports

; tunnel tiles

		call clear_tileset

updown_tiles	ld hl,#c000
		ld de,0
		ld bc,#2810
kfil1		push bc
kfil2		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		inc de
		djnz kfil2
		ld bc,#100-#28*2
		add hl,bc
		ex de,hl
		ld bc,#40-#28
		add hl,bc
		ex de,hl
		pop bc
		dec c
		jr nz,kfil1

		push hl
		ld de,#d000-#100
		ex de,hl
		ld a,#10
kfil3		ld bc,#60
		push hl
		push de
		ldir
		pop de
		pop hl
		dec h
		inc d
		dec a
		jr nz,kfil3
		pop hl
kfil4		inc hl
		set 7,(hl)
		inc hl
		ld a,h
		cp #0
		jr nz,kfil4
		ret


wave		ld a,0
		ld (wave1+1),a
		inc a
		ld (wave+1),a
		ld bc,#1daf
		ld a,4
		out (c),a
		inc b
		xor a
		out (c),a
		inc b
		ld a,Tile1_spr_page
		out (c),a
		ld b,#28
		xor a
		out (c),a
		ld b,#26
		ld a,64/4-1
		out (c),a

		ld b,240
		push bc
wave1		ld a,0
wave_adder	add a,1
		ld (wave1+1),a
		ld l,a
		ld h,high sins+1
		ld l,(hl)
		ld h,0
		add hl,hl
		add hl,hl		
		add hl,hl
		add hl,hl
		add hl,hl		
		ld de,#e000
		add hl,de
		ld bc,#1aaf
		ld a,wave_page
		out (c),l
		inc b
		out (c),h
		inc b
		out (c),a

		ld b,#27
		ld a,%00010001
		out (c),a
		call dma_stats
		pop bc
		djnz wave1-1
		ret


Twister_part
		ld hl,#6666
		ld (clr_screen_clr+1),hl
		call clr_screen
		ld hl,0
		ld (clr_screen_clr+1),hl
		ld bc,T0YOFFSL
		out (c),l
		ld de,sinsin+#100
		ld bc,#8030
		call SINMAKE
		
		ld ix,font_db
		ld hl,#1000
		ld bc,#0a06
fdb1		push bc
		ld de,#04
fdb2		ld (ix+0),l
		inc ix		
		ld (ix+0),h
		inc ix
		add hl,de
		djnz fdb2
		ld de,#100-40	; height 4 tiles
		add hl,de
		pop bc
		dec c
		jr nz,fdb1

		ld hl,#1000
		ld (clr_tileset_pal+1),hl
		call clear_tileset
		ld hl,0
		ld (clr_tileset_pal+1),hl


		ld hl,paltw
		call set_ports
		ld b,0
		ld a,%10000001
		out (c),a
		ld b,#06
		ld a,%00100000
		out (c),a
		inc b		; palsel
		ld a,#00
		out (c),a
		ld b,#16
		ld a,Tile_page
		out (c),a
		inc b
		ld a,Font_spr_page
		out (c),a
		ld b,#0f
		ld a,14
		out (c),a


		ld hl,#c000
		ld xl,0
		ld de,160
		ld b,255
		ld a,twister_page
twdb_fill	add hl,de
		jr nc,twdb_fill1
		ld h,#c0
		inc a
twdb_fill1	ld xh,high twmem_db
		ld (ix+0),l
		inc xh
		ld (ix+0),h
		inc xh
		ld (ix+0),a
		inc ix
		djnz twdb_fill
		ld xh,high twmem_db
		ld (ix+0),l
		inc xh
		ld (ix+0),h
		inc xh
		ld (ix+0),a

		ld hl,hello_adr
		ld (view_txt_adr+1),hl
		ld ix,(#beff)
		ld hl,hello_adr-#900
		ld e,l
		inc e
		ld d,h
		ld bc,#2ff
		ld (hl),l
		ldir		
		ld (#beff),ix

		ld hl,font_pal
		call set_ports


		ei
twist_loop	halt


tw_loop		ld a,(twist_count+1)
		inc a
		ld (twist_count+1),a
		or a
		jr nz,sinc
		dec a
		ld (twist_count+1),a
		ld a,#18
		ld (tw_loop),a
		ld a,22
		ld (tw_loop+1),a
sinc		ld hl,sinsin
		inc (hl)
		inc h
		inc (hl)
		inc l
		dec h
		ld (sinc+1),hl
		ld hl,stw
		call set_ports
lc2		ld a,0
		inc a
		ld (lc2+1),a
		ld (r1+1),a
		ld l,a
		add #6f
		add l
		ld (r2+1),a

twist_count	ld b,0
lc1		push bc

r1		ld a,#01
		inc a
		ld ($-2),a
		ld h,high sinsin
		ld l,a
;		ld l,(hl)
		ld c,(hl)
		inc h
r2		ld a,#01
		dec a
		ld ($-2),a
		ld l,a
		ld a,(hl)
		add c
		ld l,a
;		ld l,(hl)
		ld h,high twmem_db
		ld e,(hl)
		inc h
		ld d,(hl)
		inc h
		ld a,(hl)		
		ld bc,#1aaf
		out (c),e
		inc b
		out (c),d
		inc b
		out (c),a

		ld b,#27
		ld a,%00010001
		out (c),a
		call dma_stats
		pop bc
		djnz lc1


text_switch	ld a,0
		inc a
		cp sync_wait4
		jr nz,text_switch2
		xor a
text_switch2	ld (text_switch+1),a
		or a
		call z,view_txt
		
clr_text_switch	ld a,0
		or a
		call nz,clr_text


twist_part_count
		ld hl,4*#180+#180+1 ; test_wait
		dec hl
		ld (twist_part_count+1),hl
		ld a,h
		or l
		jp z,Tunnel_part
		jp twist_loop


view_txt	ld a,Tile_page
		ld bc,PAGE3
		out (c),a
		ld (clr_text_switch+1),a
/*
		ld hl,#c000
		ld de,#1000
		ld bc,#2810
tvfil1		push bc
tvfil2		ld (hl),e
		inc hl
		ld (hl),d
		inc hl
		inc de
		djnz tvfil2
		ld bc,#100-#28*2
		add hl,bc
		ex de,hl
		ld bc,#40-#28
		add hl,bc
		ex de,hl
		pop bc
		dec c
		jr nz,tvfil1
		ret
*/
		ld b,10
		push bc
view_char	ld hl,freak_text
		ld a,(hl)
		inc hl
		ld (view_char+1),hl
		sub #20
		add a,a
		ld l,a
		ld h,high font_db
		ld e,(hl)
		inc hl
		ld d,(hl)
view_txt_adr	ld hl,0	;+#80
		ld bc,#3c
		ld a,#04
sc1		push hl
		dup 4
		ld (hl),e
		inc l
		ld (hl),d
		inc l
		inc de
		edup
		ex de,hl
		add hl,bc
		ex de,hl
		pop hl
		inc h
		dec a
		jr nz,sc1
		pop bc
		ld a,(view_txt_adr+1)
		add 8
		ld (view_txt_adr+1),a
		djnz view_char-1
txt_posy	ld a,high hello_adr
		add 4
		cp high hello_adr+16
		jr nz,txt_posy2
		ld a,high hello_adr
txt_posy2	ld (txt_posy+1),a
		ld h,a
		ld l,0
		ld (view_txt_adr+1),hl
		ret

clr_text	ld a,0
		inc a
		cp sync_wait4
		jr nz,clr_text20
		xor a
clr_text20	ld (clr_text+1),a
		or a
		jr nz,clr_text2
		ld a,(clr_style+1)
		cpl
		ld (clr_style+1),a
		ld a,(clr_text2+2)
		add 4
		cp high hello_adr+24-9
		jr c,clr_text3

		ld a,high hello_adr-1
clr_text3	ld (clr_text2+2),a
clr_text2	ld hl,hello_adr-#900
		ld a,Tile_page
		ld bc,PAGE3
		out (c),a

clr_style	ld a,0
		or a
		jr z,clr_right
		ld b,#1a
		ld a,l
		add 2
		out (c),a
		inc b
		out (c),h
		inc b
		ld a,Tile_page
		out (c),a
		inc b
		out (c),l
		inc b
		out (c),h
		inc b
		out (c),a
		ld b,#26
		ld a,80/2-1
		out (c),a
		inc b
		inc b
		ld a,4
		out (c),a
		dec b
		ld a,%00110001
		out (c),a
		jp dma_stats

clr_right	dec hl
		dec hl
		ld de,#4e
		add hl,de
		ld e,l
		inc e
		inc e
		ld d,h
		di
		ld ix,(#beff)	; shit. INT adress cleared.
		ld bc,#2805
clr_right1	push hl
		push de
		push bc
		ld a,(hl)
		ld (de),a
		dec hl
		dec de
		ld a,(hl)
		ld (de),a
		dec hl
		dec de
		djnz $-8
		pop bc
		pop de
		pop hl
		inc d
		inc h
		dec c
		jr nz,clr_right1
		ld (#beff),ix
		ei
		ret

		;   123456789a
freak_text	db " HI SCENE!"
		db "BUYAN,EARL"
		db "DIVER,NQ! "
		db "TREFI,G.D "
		db "INTROSPEC!"
		db "CRASH,NYUK"
		db "ROBUS,TSL "
		db "NODEUS,AAA"
		db "          "
		db "HB PSNDCJ!"		
		db " HI 3BM!  "
		db "          "
		db "DEMO: VBI "
		db "MFX:KEYJEE"
		db "    C-JEFF"
		db "          "
		db "          "
		db " DEMO OR  "
		db "   DIE!   "

kalidoskop_part_copy
		defb #1a,0
		defb #1b,0
		defb #1c,kali1_spr_page
		defb #1d,0
		defb #1e,0
		defb #1f,kali1_spr_part_page
		defb #26,160/4-1
		defb #28,240/2-1
		defb #27,%00110001
		db #ff

kalidoskop2_part_copy
		defb #1a,0
		defb #1b,0
		defb #1c,kali2_spr_page
		defb #1d,0
		defb #1e,0
		defb #1f,kali2_spr_part_page
		defb #26,160/4-1
		defb #28,320/2-1		
		defb #27,%00110001
		db #ff

kali1_copy	defb #1a,0
		defb #1b,0
		defb #1c,kali1_page
		defb #1d,0
		defb #1e,0
		defb #1f,kali1_spr_page
		defb #26,480/4-1	
		defb #28,480/2-1		
		defb #27,%00010001
		db #ff

kali1_pal
		defb    #1a,0
	        defb    #1b,#c8
		defb    #1c,kali1_pal_page
	        defb    #1d,0
	        defb    #1e,0
	        defb    #1f,0
	        defb    #26,16
	        defb    #28,0
		db 	#27,#84
		db #ff

kali2_copy	defb #1a,0
		defb #1b,0
		defb #1c,kali2_page
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,kali2_spr_page
		defb #26,320/4-1	;
		defb #28,160-1		;144
		defb #27,%00010001
		db #ff

kali2_pal
		defb    #1a,0
	        defb    #1b,#ca
		defb    #1c,kali2_pal_page

	        defb    #1d,#20
	        defb    #1e,0
	        defb    #1f,0
	        defb    #26,16
	        defb    #28,0
		db 	#27,#84
		db #ff

paltw			; palitra
		defb    #1a,0
	        defb    #1b,#f8		
		defb    #1c,26
	        defb    #1d,0
	        defb    #1e,0
	        defb    #1f,0
	        defb    #26,16
	        defb    #28,0
		db 	#27,#84
		db #ff

stw
		db #1a,0
		db #1b,0
		db #1c,twister_page	;
		db #1d,0	;
		db #1e,0	;
		db #1f,Vid_page	;
		db #26,(320/4)-1	;(164/2)-1
		db #28,0	;

		db #ff


tw		db #1a,0
		db #1b,0
		db #1c,twister_page	;
		db #ff


font_copy	defb #1a,0
		defb #1b,0
		defb #1c,font_page
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,Font_spr_page
		defb #26,320/4-1	;
		defb #28,192-1		;144
		defb #27,%00010001
		db #ff

font_pal
		defb    #1a,0
	        defb    #1b,#f8
		defb    #1c,font_page+1
	        defb    #1d,#20
	        defb    #1e,0
	        defb    #1f,0
	        defb    #26,16
	        defb    #28,0
		db 	#27,#84
		db #ff


waveset_copy	defb #1a,0
		defb #1b,0
		defb #1c,tunnel_page
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,Tile0_spr_page
		defb #26,80-1	;
		defb #28,137-1		;256, (384)-1
		defb #27,%00010001
		defb #ff

wave_pal_init	
		defb    #1a,0
	        defb    #1b,#f4
		defb    #1c,rubik_page
	        defb    #1d,#20
	        defb    #1e,0
	        defb    #1f,0
	        defb    #26,16
	        defb    #28,0
		db 	#27,#84
		db #ff



rubik_tset_copy
		defb #1a,0
		defb #1b,0
		defb #1c,rubik_page
		defb #1d,0
		defb #1e,0
		defb #1f,rubik_spr_page
		defb #26,128/4-1
		defb #28,128-1		;256, (384)-1
		defb #27,%00010001
		db #ff

rubik_pal_init
		defb    #1a,0
	        defb    #1b,#f2
		defb    #1c,rubik_page
	        defb    #1d,#40
	        defb    #1e,0
	        defb    #1f,0
	        defb    #26,16
	        defb    #28,0
		db 	#27,#84
		db #ff

rubik_spr
		defb    #1a,0
	        defb    #1b,high spr_db
		defb    #1c,2
	        defb    #1d,0
	        defb    #1e,2
	        defb    #1f,0
	        defb    #26,7*6
	        defb    #28,0
		db 	#27,#85
		db #ff

clr_spr
		defb #1a,0	;
		defb #1b,0	;
		defb #1c,rubik_spr_page	;
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,rubik_spr_page	;

		defb #28,#ff	;
		defb #26,#ff	;
		defb #27,%00000100
		db #ff
rubikon_logo_ports
		defb #1a,0
		defb #1b,0
		defb #1c,rubikon_logo_page
		defb #1d,0
		defb #1e,0
		defb #1f,rubik_spr_page
		defb #26,336/4-1
		defb #28,48-1		;256, (384)-1
		defb #27,%00010001
		db #ff

rubikon_logo_pal
		defb    #1a,0
	        defb    #1b,#f6
		defb    #1c,rubikon_pal_page
	        defb    #1d,0
	        defb    #1e,0
	        defb    #1f,0
	        defb    #26,16
	        defb    #28,0
		db 	#27,#84
		db #ff

rubikon_bottom_ports
		defb #1a,0
		defb #1b,#e0
		defb #1c,rubic_bottom_page
		defb #1d,0
		defb #1e,0
		defb #1f,Tile0_spr_page
		defb #26,320/4-1
		defb #28,49-1		;256, (384)-1
		defb #27,%00010001
		db #ff

rubikon_bottom_pal
		defb    #1a,0
	        defb    #1b,#d2
		defb    #1c,24		; page rubikon_bottom palitra
	        defb    #1d,#20
	        defb    #1e,0
	        defb    #1f,0
	        defb    #26,16
	        defb    #28,0
		db 	#27,#84
		db #ff


julia_bin
		defb #1a,0
		defb #1b,0
		defb #1c,julia_page	; there be "Julia, I Love You!" pic for my wife ;)
		defb #1d,#20		; now - this is credits pic
		defb #1e,#04
		defb #1f,Vid_page+2
		defb #26,180/4-1
		defb #28,30-1		;256, (384)-1
		defb #27,%00010001
		db #ff

julia_pal
		defb    #1a,0
	        defb    #1b,#d2
		defb    #1c,julia_page	; page rubikon_bottom palitra
	        defb    #1d,#20
	        defb    #1e,0
	        defb    #1f,0
	        defb    #26,16
	        defb    #28,0
		db 	#27,#84
		db #ff

rubikon_logo_spr
		defb    #1a,low logo_spr
	        defb    #1b,high logo_spr
		defb    #1c,2
	        defb    #1d,0
	        defb    #1e,2
	        defb    #1f,0
	        defb    #26,10*6
	        defb    #28,0
		db 	#27,#85
		db #ff


screen_init	defb #00,%10100001	;VCONFIG
		defb #01,Vid_page	;VPAGE
		defb #20,6	; SYSCONFIG
		defb #0f,3	; border

screen_init_clr	defb #1a,0	;
		defb #1b,0	;
		defb #1c,Vid_page	;
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,Vid_page	;

		defb #28,200	;
		defb #26,#ff	;
		defb #27,%00000100
		db #ff

tileset_clr
		defb #1a,0	;
		defb #1b,0	;
		defb #1c,Tile_page	;
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,Tile_page	;
		defb #28,#ff	;
		defb #26,#1f	;
		defb #27,%00000100
		db #ff
tile0_spr_init	
		defb #1a,0	;
		defb #1b,0	;
		defb #1c,Tile0_spr_page
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,Tile0_spr_page	;

		defb #28,200	;
		defb #26,#ff	;
		defb #27,%00000100
		db #ff

tileset_copy	defb #1a,0
		defb #1b,0
		defb #1c,tunnel_page
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,Tile0_spr_page
		defb #26,80-1	;
		defb #28,137-1		;256, (384)-1
		defb #27,%00010001
		db #ff

tunnel_pal_init
		defb    #1a,0
	        defb    #1b,#d0
		defb    #1c,24
	        defb    #1d,0
	        defb    #1e,0
	        defb    #1f,0
	        defb    #26,16
	        defb    #28,0
		db 	#27,#84
		db #ff


int		push af
		push hl
		push de
		push bc
		ld bc,PAGE3
		ld a,mus_page
		out (c),a
		call music+5

nxt_int1
		ld a,1
		ld (wait_counter2+1),a
timecount	ld hl,0
		inc hl
		ld (timecount+1),hl
nxt_int2
		pop bc
		pop de
		pop hl
		pop af

		ei
		ret

line_proc	
		exx
		ex af,af
wav_pos		ld hl,0
		inc hl
		ld (wav_pos+1),hl
		ld a,(hl)
		out (#fb),a	; Covox, snd Loopz!
		ex af,af
		exx
		ei
		ret

im2_init	
		xor a	
		ld	bc,HSINT
		out	(c),a
		ld	bc,VSINTL
		out	(c),a
		ld	bc,VSINTH
		out	(c),a
		ld e,8
		ld b,#40
		call clr_port
		ld b,#02
		ld e,4
 		call clr_port
		ld b,#0f
		out (c),a
		ld	a,#be
		ld	i,a
		ld	hl,int
		ld	(#beff),hl
		im	2
		ret

clear_tileset	ld bc,PAGE3
	    	ld a,Tile_page
		out (c),a
clr_tileset_pal	ld hl,0
		ld (#c000),hl
		ld hl,tileset_clr
		jp set_ports

clr_port	out (c),a
		inc b
		dec e
		jr nz,$-4
		ret

set_ports	ld c,#af
		ld a,(hl)
		cp #ff
		jr z,dma_stats
		ld b,a
		inc hl
		ld a,(hl)
		inc hl
		out (c),a
		jr set_ports+2

dma_stats	ld bc,DMASTATUS
		in a,(c)
		AND #80
		jr nz,$-4
		ret


SINMAKE INC     C
        LD      HL,SIN_DAT
        PUSH    BC
        LD      B,E
LP_SMK1 PUSH    HL
        LD      H,(HL)
        LD      L,B
        LD      A,#08
LP_SMK2 ADD     HL,HL
        JR      NC,$+3
        ADD     HL,BC
        DEC     A
        JR      NZ,LP_SMK2
        LD      A,H
        LD      (DE),A
        POP     HL
        INC     HL
        INC     E
        BIT     6,E
        JR      Z,LP_SMK1
        LD      H,D
        LD      L,E
        DEC     L
        LD      A,(HL)
        LD      (DE),A
        INC     E
LP_SMK3 LD      A,(HL)
        LD      (DE),A
        INC     E
        DEC     L
        JR      NZ,LP_SMK3
LP_SMK4 LD      A,(HL)
        NEG
        LD      (DE),A
        INC     L
        INC     E
        JR      NZ,LP_SMK4
        POP     BC
LP_SMK5 LD      A,(DE)
        ADD     A,B
        LD      (DE),A
        INC     E
        JR      NZ,LP_SMK5
	di
        RET

SIN_DAT
	  DB  #00,#06,#0D,#13,#19,#1F,#25,#2C
	  DB  #32,#38,#3E,#44,#4A,#50,#56,#5C
	  DB  #62,#67,#6D,#73,#78,#7E,#83,#88
	  DB  #8E,#93,#98,#9D,#A2,#A7,#AB,#B0
	  DB  #B4,#B9,#BD,#C1,#C5,#C9,#CD,#D0
	  DB  #D4,#D7,#DB,#DE,#E1,#E4,#E7,#E9
	  DB  #EC,#EE,#F0,#F2,#F4,#F6,#F7,#F9
	  DB  #FA,#FB,#FC,#FD,#FE,#FE,#FF,#FF


		org (high $+1) *#100	; ALIGN 256
spr_db		
		DB 0
		DB %01000000	; leap
		DB 0
		DB %00010000
		DB 0
		DB %11100000

		DB 0
		DB %01000000	; leap
		DB 0
		DB %00010000
		DB 0
		DB %11100000

spr1		db 0
		db %00111110
		db 96
		db %00001110
		db 0
		db %00100000

spr2		db 0
		db %00111110
		db 96+64
		db %00001110
		db 8
		db %00100000

spr3		db 64
		db %00111110
		db 96
		db %00001110
		db 0
		db %00100010

spr4		db 64
		db %00111110
		db 96+64
		db %00001110
		db 8
		db %00100010	

		DB 0		;exit
		DB %01000000	; leap
		DB 0
		DB %00010000
		DB 0
		DB %11100000
spr_db_end



logo_spr

logo_spr1	db 0
		db %00011010
		db 0+5
		db %00001010
		db 0
		db %00000000

logo_spr2	db 0
		db %00011010
		db 6*8-4+5
		db %00001010
		db 6
		db %00000000

logo_spr3	db 0
		db %00011010
		db 12*8-4*2+4
		db %00001010
		db 12
		db %00000000

logo_spr4	db 0
		db %00011010
		db 18*8-4*3+4
		db %00001010
		db 18
		db %00000000

logo_spr5	db 0
		db %00011010
		db 24*8-4*4+4
		db %00001010
		db 24
		db %00000000

logo_spr6	db 0
		db %00011010
		db 30*8-4*5+3
		db %00001010
		db 30
		db %00000000

logo_spr7	db 0
		db %00011010
		db 9+3	; 36*8-4*6
		db %00001011
		db 36
		db %00000000

logo_spr_ex	DB 0
		DB %01000000	; leap
		DB 0
		DB %00010000
		DB 0
		DB %11100000

		DB 0
		DB %01000000	; leap
		DB 0
		DB %00010000
		DB 0
		DB %11100000

		DB 0		;exit
		DB %01000000	; leap
		DB 0
		DB %00010000
		DB 0
		DB %11100000
logo_spr_end

		include "tsconfig.asm"

lines_colors	
		dw color3

		dup #0f
		dw color1
		edup 

		dw color4

		dup #0f
		dw color2
		edup 
lines_colors_end
		db #ff

color1		equ #6040
color2		equ #6300
color3		equ #61a0
color4		equ #6160

lines_pal
		defb    #1a,0
	        defb    #1b,high lines_color_db
		defb    #1c,5
	        defb    #1d,0
	        defb    #1e,1
	        defb    #1f,0
	        defb    #26,#7f
	        defb    #28,0
		db 	#27,#84
		db #ff


lines		defb #1a,0
		defb #1b,0
		defb #1c,lines_page
		defb #1d,0	;
		defb #1e,0	;
		defb #1f,Vid_page
		defb #26,160-1	;
		defb #28,200-1	;
		defb #27,%00011001
		db #ff


sin_tunnel	incbin "sin.bin"	
		

		
		align 256
sinsin		incbin "_spg/tw_sin.bin"
		ds 1	; ds 256 - второй синус

		align 256
twmem_db		;	 len: #300


end
	SAVEBIN "_spg/rubicon.bin",start, end-start