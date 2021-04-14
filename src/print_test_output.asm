INCLUDE "defines.asm"

SECTION "Print Test Output", ROM0
PrintTestOutput::
	xor a
	ldh [hLCDC],a
	rst WaitVBlank
	ld hl,_VRAM
	ld de,FontTiles
	ld bc,FontTilesEnd-FontTiles
	call Memcpy

	ld hl,_SCRN0
	ld de,wTestOutput
	ld c,16
.loop
	rst MemcpySmall
	ld c,16
	add hl,bc
	bit 1,h
	jr z,.loop
	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_BGON
	ldh [hLCDC],a
	ldh [rLCDC],a
	ret
	
	
	
SECTION "Font", ROM0

FontTiles:
INCBIN "test_font.chr"
FontTilesEnd: