INCLUDE "defines.asm"

TestOutputLength EQU 256

SECTION "Intro", ROMX

Intro::
; Put your code here!
; Put your code here!
InitTest:
	ld a,CART_SRAM_ENABLE
	ld [rRAMG],a
	xor a ; ld a,0
	ld [rRAMB],a
	ld [_SRAM],a
	ld hl, RAMGMemcpy
	lb bc, RAMGMemcpy.end - RAMGMemcpy, LOW(hRAMGMemcpy)
.copyRAMGMemcpy
	ld a,[hli]
	ldh [c],a
	inc c
	dec b
	jr nz,.copyRAMGMemcpy
	
Test:
	call hRAMGMemcpy
	call PrintTestOutput
.hang
	jr .hang

SECTION "RAMG Memcpy Routine", ROMX
RAMGMemcpy:
	ld hl,wTestOutput
	ld bc,_SRAM
	ld de,rRAMG
.loop
	ld a,e
	ld [de],a
	ld a,[bc]
	inc a
	ld [hli],a
	inc e
	jr nz,.loop
	ret
.end

SECTION "Test Output", WRAM0
wTestOutput::
	ds TestOutputLength


SECTION "RAMG Memcpy", HRAM
hRAMGMemcpy::
	ds RAMGMemcpy.end - RAMGMemcpy
