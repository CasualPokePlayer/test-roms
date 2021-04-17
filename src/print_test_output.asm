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
	ld bc,18
	push bc
.loop
	ld c,20
	rst MemcpySmall
	pop bc
	dec c
	jr z,.done
	push bc
	ld c,12
	add hl,bc
	jr .loop
.done
	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_BGON
	ldh [hLCDC],a
	ldh [rLCDC],a
	ret
	
	
	
SECTION "Font", ROM0

FontTiles:
INCBIN "test_font.chr"
FontTilesEnd: