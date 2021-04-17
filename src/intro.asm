INCLUDE "defines.asm"

TestOutputLength EQU 416

SECTION "Test Output", WRAM0
wTestOutput::
	ds TestOutputLength
	
SECTION "SP", WRAM0
wSP:
	ds 2

SECTION "Intro", ROMX

Intro::
; Put your code here!
	xor a
	ld [rRAMG],a ; just in case
	ld hl,wTestOutput
	call a_bc
	; hl = wTestOutput+$10
	call a_de
	ld de,wTestOutput+$20
	call a_hli
	; de = wTestOutput+$30
	call a_hld
	; de = wTestOutput+$40
	call b_hl
	; de = wTestOutput+$50
	call c_hl
	ld bc,wTestOutput+$60
	call d_hl
	; bc = wTestOutput+$70
	call e_hl
	; bc = wTestOutput+$80
	call h_hl
	; bc = wTestOutput+$90
	call l_hl
	; bc = wTestOutput+$A0
	call a_hl
	; bc = wTestOutput+$B0
	call add_hl
	; bc = wTestOutput+$C0
	call adc_hl
	; bc = wTestOutput+$D0
	call sub_hl
	; bc = wTestOutput+$E0
	call sbc_hl
	; bc = wTestOutput+$F0
	call and_hl
	; bc = wTestOutput+$100
	call xor_hl
	; bc = wTestOutput+$110
	call or_hl
	; bc = wTestOutput+$120
	call cp_hl
	; bc = wTestOutput+$130
	call a_n16
	; pop is tricky, so let's place this last
	ld de,wTestOutput+$140
	call pop_bc 
	ld bc,wTestOutput+$150
	call pop_de
	; bc = wTestOutput+$160
	call pop_hl
	; bc = wTestOutput+$180
	call PrintTestOutput
.hang
	jr .hang
	
	
a_bc:
	ld bc,_SRAM
	REPT 16
	ld a,[bc]
	ld [hli],a
	ENDR
	ret

a_de:
	ld de,_SRAM
	REPT 16
	ld a,[de]
	ld [hli],a
	ENDR
	ret
	
a_hli:
	ld hl,_SRAM
	REPT 16
	ld a,[hli]
	ld [de],a
	inc de
	ENDR
	ret
	
a_hld:
	ld hl,_SRAM+$10
	REPT 16
	ld a,[hld]
	ld [de],a
	inc de
	ENDR
	ret
	
b_hl:
	ld hl,_SRAM
	REPT 16
	ld b,[hl]
	ld a,b
	ld [de],a
	inc de
	ENDR
	ret
	
c_hl:
	ld hl,_SRAM
	REPT 16
	ld c,[hl]
	ld a,c
	ld [de],a
	inc de
	ENDR
	ret
	
d_hl:
	ld hl,_SRAM
	REPT 16
	ld d,[hl]
	ld a,d
	ld [bc],a
	inc bc
	ENDR
	ret

e_hl:
	ld hl,_SRAM
	REPT 16
	ld e,[hl]
	ld a,e
	ld [bc],a
	inc bc
	ENDR
	ret
	
h_hl:
	ld l,$00
	REPT 16
	ld h,$A0
	ld h,[hl]
	ld a,h
	ld [bc],a
	inc bc
	ENDR
	ret
	
l_hl:
	ld h,HIGH(_SRAM)
	REPT 16
	ld l,LOW(_SRAM)
	ld l,[hl]
	ld a,l
	ld [bc],a
	inc bc
	ENDR
	ret
	
a_hl:
	ld hl,_SRAM
	REPT 16
	ld a,[hl]
	ld [bc],a
	inc bc
	ENDR
	ret
	
add_hl:
	ld hl,_SRAM
	REPT 16
	xor a
	add [hl]
	ld [bc],a
	inc bc
	ENDR
	ret
	
adc_hl:
	ld hl,_SRAM
	REPT 16
	xor a
	adc [hl]
	ld [bc],a
	inc bc
	ENDR
	ret
	
sub_hl:
	ld hl,_SRAM
	REPT 16
	xor a
	sub [hl]
	cpl ; we want what was read from [hl]
	inc a
	ld [bc],a
	inc bc
	ENDR
	ret
	
sbc_hl:
	ld hl,_SRAM
	REPT 16
	xor a
	sbc [hl]
	cpl ; same here
	inc a
	ld [bc],a
	inc bc
	ENDR
	ret
	
and_hl:
	ld hl,_SRAM
	REPT 16
	ld a,$FF
	and [hl]
	ld [bc],a
	inc bc
	ENDR
	ret
	
xor_hl:
	ld hl,_SRAM
	REPT 16
	xor a
	xor [hl]
	ld [bc],a
	inc bc
	ENDR
	ret
	
or_hl:
	ld hl,_SRAM
	REPT 16
	xor a
	or [hl]
	ld [bc],a
	inc bc
	ENDR
	ret
	
cp_hl: ; things get tricky here
	ld hl,_SRAM
	ld e,$10 ; loop through the code 16 times
.loop_start
	ld a,$FF
.loop
	inc a
	cp [hl]
	jr nz,.loop ; keep looping until we find a match for HL
	ld [bc],a
	inc bc
	dec e
	jr nz,.loop_start
	ret
	
a_n16:
	REPT 16
	ld a,[_SRAM]
	ld [bc],a
	inc bc
	ENDR
	ret
	
pop_bc:
	di
	ld [wSP],sp
	ld sp,_SRAM
	REPT 8
	pop bc
	ld a,c
	ld [de],a
	inc de
	ld a,b
	ld [de],a
	inc de
	ENDR
	ld sp,wSP
	pop hl
	ld sp,hl
	reti
	
pop_de:
	di
	ld [wSP],sp
	ld sp,_SRAM
	REPT 8
	pop de
	ld a,e
	ld [bc],a
	inc bc
	ld a,d
	ld [bc],a
	inc bc
	ENDR
	ld sp,wSP
	pop hl
	ld sp,hl
	reti

pop_hl:
	di
	ld [wSP],sp
	ld sp,_SRAM
	REPT 8
	pop hl
	ld a,l
	ld [bc],a
	inc bc
	ld a,h
	ld [bc],a
	inc bc
	ENDR
	ld sp,wSP
	pop hl
	ld sp,hl
	reti

