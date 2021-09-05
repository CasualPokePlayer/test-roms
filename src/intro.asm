INCLUDE "defines.asm"

TestOutputLength EQU 256

test_joyp: MACRO
	ld a,(\1)
	ldh [rP1],a
	ld a,(\2)
	ldh [rP1],a
	ldh a,[rP1]
	ld [hli],a
	inc hl
ENDM

SECTION "Intro", ROMX
Intro::
; Put your code here!
InitTest:
	di
	ld hl,MLT_REQ_PACKET
	call SGBDelay
	call SendPacketNoDelay
REPT 16
	call SGBDelay
ENDR
	ld hl,wTestOutput
	xor a
	ld c,a
	rst MemsetSmall
Test:
	ld hl,wTestOutput
REPT 8
	test_joyp $10, $20
ENDR
REPT 8
	test_joyp $20, $10
ENDR
REPT 8
	test_joyp $20, $00
ENDR
REPT 8
	test_joyp $00, $20
ENDR
REPT 8
	test_joyp $10, $00
ENDR
REPT 8
	test_joyp $00, $10
ENDR
	ei
	call PrintTestOutput
.hang
	jr .hang
MLT_REQ_PACKET:
	sgb_packet MLT_REQ, 1, 1

SECTION "Test Output", WRAM0
wTestOutput::
	ds TestOutputLength
