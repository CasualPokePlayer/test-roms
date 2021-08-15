INCLUDE "defines.asm"

CAM_TESTS = 0
VRAM_OFFSET = 0

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
	ld [_SCRN0+CAM_TESTS+VRAM_OFFSET+1],a
CAM_TESTS = CAM_TESTS + 2
IF CAM_TESTS % 16 == 0 ; next line now
VRAM_OFFSET = VRAM_OFFSET + 16
ENDC
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
	xor a
	ld [$A001],a ; unset n bit
	ld [$A002],a ; clear exposure
	ld a,1
	ld [$A003],a
Tests:
REPT 128
	cam_test 4635+73, 3+16
ENDR
	xor a
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,1
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,2
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,3
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,4
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,5
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,6
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,7
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,8
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,9
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,10
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,11
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,12
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,13
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,14
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
	ld a,15
	ld [$4000],a
	ld a,$FF
	ld hl,$A000
	ld bc,$2000
	call wTestsEnd - (TestsEnd-.memsetloop)
.lockup
	jr .lockup
.memsetloop
	ld [hli],a
	dec bc
	ld a,b
	or c
	jr nz,.memsetloop
	ret
TestsEnd:

SECTION "Tests WRAM", WRAM0
wTestOutput:: ; needed for building due to test rom framework, although doesn't matter the size as long as it's cleared out correctly (256 bytes)

wTestsStart:
	ds TestsEnd-TestsStart
wTestsEnd:

SECTION "Intro", ROMX
Intro::
	ld a,$FF
	ld hl,wTestOutput
	ld c,$00
	rst MemsetSmall
	call PrintTestOutput
	ld hl,wTestsStart
	ld de,TestsStart
	ld bc,TestsEnd-TestsStart
	call Memcpy
	jp wTestsStart	
