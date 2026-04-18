INCLUDE "defines.asm"

rRTCL EQU $6000 ; rtc latch
TestOutputLength EQU 260

SECTION "Intro", ROMX

Intro::
; Put your code here!
InitTest:
	ld a,CART_SRAM_ENABLE
	ld [rRAMG],a
	ld hl,randstate
	xor a
	ld [hli],a
	ld [hli],a
	ld [hli],a
	ld [hl],a
	ld bc,_SRAM
	ld de,rRAMB
	ld a,$08
REPT 5
	ld [de],a
	push af
	xor a
	ld [bc],a
	pop af
	inc a
ENDR
	xor a
	ld [rRTCL],a
	inc a
	ld [rRTCL],a
Test:
	ld hl,wTestOutput
REPT 52
	push hl
	call RandomizeRTC
	pop hl
	call ReportRTC
	push hl
	push de
	push bc
	call rand
	pop bc
	pop de
	pop hl
	ld [rRTCL],a
ENDR
	call PrintTestOutput
.hang
	jr .hang

SECTION "Test Output", WRAM0
wTestOutput::
	ds TestOutputLength

SECTION "functions", ROMX
RandomizeRTC:
	ld bc,_SRAM
	ld de,rRAMB
	ld a,$08
REPT 5
	ld [de],a
	push af
	push bc
	push de
	call rand
	pop de
	pop bc
	ld [bc],a
	pop af
	inc a
ENDR
	ret

ReportRTC:
	ld bc,_SRAM
	ld de,rRAMB
	ld a,$08
REPT 5
	ld [de],a
	push af
	ld a,[bc]
	ld [hli],a
	pop af
	inc a
ENDR
	ret
