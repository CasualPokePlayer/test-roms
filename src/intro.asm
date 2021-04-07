INCLUDE "defines.asm"

rRTCL EQU $6000 ; rtc latch
TestOutputLength EQU 256

SECTION "Intro", ROMX

Intro::
; Put your code here!
InitTest:
	ld a,CART_SRAM_ENABLE
	ld [rRAMG],a
	ld bc,_SRAM
	ld de,rRAMB
	ld a,16
.loop
	dec a
	ld [de],a
	ld [bc],a
	jr nz,.loop
	
	; xor a
	ld [rRTCL],a
	inc a
	ld [rRTCL],a
	
	ld hl, RTCMemcpy
	lb bc, RTCMemcpy.end - RTCMemcpy, LOW(hRTCMemcpy)
.copyRTCMemcpy
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, .copyRTCMemcpy
	
Test:
	call hRTCMemcpy
	call PrintTestOutput
.hang
	jr .hang

SECTION "RTC Memcpy Routine", ROMX
RTCMemcpy:
	ld hl,wTestOutput
	ld bc,_SRAM
	ld de,rRAMB
.loop
	ld a,e
	ld [de],a
	ld a,[bc]
	ld [hli],a
	inc e
	jr nz,.loop
	ret
.end

SECTION "Test Output", WRAM0
wTestOutput::
	ds TestOutputLength


SECTION "RTC Memcpy", HRAM
hRTCMemcpy::
	ds RTCMemcpy.end - RTCMemcpy
