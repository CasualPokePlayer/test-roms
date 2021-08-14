INCLUDE "defines.asm"

CAM_TESTS = 0

cam_test: MACRO
CamTest\@:
	ld a,1
	ld hl,$A000
	ld bc,(\1)
	ld [hl],a ; 1 cycle here after write (for gambatte boundaries)
.waitloop\@
	dec bc
	ld a,b
	or c
	jr nz,.waitloop\@ ; each loop is 7 cycles, 6 for last iteration
IF _NARG == 2 && (\2) > 0
REPT (\2)
	nop ; 1 cycle each nop
ENDR
ENDC
	ld b,[hl] ; 1 cycle here before read
	inc b
	wait_vram
	ld a,b
	ld [_SCRN0+CAM_TESTS],a
CAM_TESTS = CAM_TESTS + 1
.wait\@
	ld a,[$A000]
	and 1
	jr nz,.wait\@ ; just in case
ENDM

SECTION "Tests", ROMX ; to be copied over to wram
TestsStart:
WaitCartSwap:
	di
	ld a,1
	ldh [rIE],a
	xor a
	ld hl,rIF
	ld e,$00
	ld [hl],e
	ld bc,600
.loop
	halt
	nop
	ld [hl],e
	dec bc
	ld a,b
	or c
	jr nz,.loop
TestSetup:
	ld a,$10
	ld [$4000],a
	ld a,$0A
	ld [$0000],a ; this shouldnt be needed, but just in case
.wait
	ld a,[$A000]
	and 1
	jr nz,.wait ; just in case
	ld a,$20
	ld [$A001],a ; unset n bit, set vh = 1
	xor a
	ld [$A002],a ; clear exposure
	ld [$A003],a
Tests:
	cam_test 4635+73, 2
	cam_test 4635+73, 3
	cam_test 4635+73, 4
	cam_test 4635+73, 5
	cam_test 4635+73, 6
	cam_test 4635+73, 7
	cam_test 4635+73, 8
.lockup
	jr .lockup
TestsEnd:

SECTION "Test Output", WRAM0
wTestOutput::
	ds 256

wTestsStart:
	ds TestsEnd-TestsStart
wTestsEnd:

SECTION "Intro", ROMX
Intro::
	xor a
	ld hl,wTestOutput
	ld c,a
	rst MemsetSmall
	call PrintTestOutput
	ld hl,wTestsStart
	ld de,TestsStart
	ld bc,TestsEnd-TestsStart
	call Memcpy
	jp wTestsStart
	
	
