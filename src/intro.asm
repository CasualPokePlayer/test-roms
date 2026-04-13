INCLUDE "defines.asm"

TestOutputLength EQU 256

; first arg: packet data
; second arg: function to send packet
test_packet: MACRO
	push hl
	ld hl,\1
	call \2
	call SGBDelay
	call GetPlayerCount
	pop hl
	ld [hli],a
ENDM

SECTION "Intro", ROMX
Intro::
InitTest:
	di

	; not sure if this is needed?
	ld hl,MLT_REQ_2P_PACKET
	call SGBDelay
	call SendPacketNoDelay
REPT 16
	call SGBDelay
ENDR

	ld hl,wTestOutput
	xor a
	ld c,a
	rst MemsetSmall
	ld hl,_SCRN0
	ld bc,$234
	call LCDMemset
Test:
	ld hl,wTestOutput

	test_packet MLT_REQ_4P_PACKET, SendPacketBasic
	test_packet MLT_REQ_1P_PACKET, SendPacketBasic

	test_packet MLT_REQ_4P_PACKET, SendPacketCorruptStop
	test_packet MLT_REQ_1P_PACKET, SendPacketCorruptStop

	test_packet MLT_REQ_4P_PACKET, SendPacketAvoid30
	test_packet MLT_REQ_1P_PACKET, SendPacketAvoid30

	test_packet MLT_REQ_4P_PACKET, SendPacket20To10
	test_packet MLT_REQ_2P_PACKET, SendPacket20To10
	test_packet MLT_REQ_1P_PACKET, SendPacket20To10

	test_packet MLT_REQ_4P_PACKET, SendPacket10To20
	test_packet MLT_REQ_2P_PACKET, SendPacket10To20
	test_packet MLT_REQ_1P_PACKET, SendPacket10To20

	test_packet MLT_REQ_4P_PACKET, SendPacket00To10
	test_packet MLT_REQ_2P_PACKET, SendPacket00To10
	test_packet MLT_REQ_1P_PACKET, SendPacket00To10

	test_packet MLT_REQ_4P_PACKET, SendPacket00To20
	test_packet MLT_REQ_2P_PACKET, SendPacket00To20
	test_packet MLT_REQ_1P_PACKET, SendPacket00To20

	test_packet MLT_REQ_4P_PACKET, SendPacket10To00
	test_packet MLT_REQ_2P_PACKET, SendPacket10To00
	test_packet MLT_REQ_1P_PACKET, SendPacket10To00

	test_packet MLT_REQ_4P_PACKET, SendPacket20To00
	test_packet MLT_REQ_2P_PACKET, SendPacket20To00
	test_packet MLT_REQ_1P_PACKET, SendPacket20To00

	test_packet MLT_REQ_4P_PACKET, SendPacketShortStart
	test_packet MLT_REQ_2P_PACKET, SendPacketShortStart
	test_packet MLT_REQ_1P_PACKET, SendPacketShortStart

	ei
	call PrintTestOutput
.hang
	jr .hang

MLT_REQ_1P_PACKET:
	db (MLT_REQ << 3) | 1, $00
	ds SGB_PACKET_SIZE - 2, 0
MLT_REQ_2P_PACKET:
	db (MLT_REQ << 3) | 1, $01
	ds SGB_PACKET_SIZE - 2, 0
MLT_REQ_4P_PACKET:
	db (MLT_REQ << 3) | 1, $03
	ds SGB_PACKET_SIZE - 2, 0

SendPacketBasic:
	jp SendPacketNoDelay

SendPacketCorruptStop:
	; Packet transmission begins by sending $00 then $30
	xor a
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$10 ; 1 bits are sent with $10
	rr e ; Rotate e and get its lower bit, two birds in one stone!
	jr c,.bitSet
	add a,a ; 0 bits are sent with $20
.bitSet
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	dec b
	jr nz,.sendByte

	; Packets are normally terminated by a "STOP" 0 bit
	; We'll send a "corrupt" STOP 1 bit
	ld a,$10
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

SendPacketAvoid30:
	; Packet transmission normally begins by sending $00 then $30
	; Maybe it actually begins with both bits going high to low at the same time
	ld a,$30
	ldh [rP1],a
	xor a
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$20 ; 1 bits are sent with $30 -> $10 (i.e. high to low in bit 5?)
	rr e ; Rotate e and get its lower bit, two birds in one stone!
	jr c,.bitSet
	ld a,$10 ; 0 bits are sent with $30 -> $20 (i.e. high to low in bit 4?)
.bitSet
	ldh [rP1],a
	xor a ; Do high to low
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	dec b
	jr nz,.sendByte

	; Packets are terminated by a "STOP" 0 bit
	ld a,$10
	ldh [rP1],a
	xor a
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

SendPacket20To10:
	; Packet transmission begins by sending $00 then $30
	xor a
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$10 ; 1 bits are sent with $10
	rr e ; Rotate e and get its lower bit, two birds in one stone!
	jr c,.bitSet
	add a,a ; 0 bits are sent with $20
.bitSet
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	ld a,b
	cp a,SGB_PACKET_SIZE
	jr nz,.nextByte

	; write the first bit of joypad mask with 20 -> 10 -> 30
	ld a,$20
	ldh [rP1],a
	ld a,$10
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a

	; write the next 7 bits and bytes
	dec b
	ld d,8
	ld a,[hli]
	ld e,a
	rr e
	dec d
	jr .sendBit

.nextByte
	dec b
	jr nz,.sendByte

	; Packets are terminated by a "STOP" 0 bit
	ld a,$20
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

SendPacket10To20:
	; Packet transmission begins by sending $00 then $30
	xor a
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$10 ; 1 bits are sent with $10
	rr e ; Rotate e and get its lower bit, two birds in one stone!
	jr c,.bitSet
	add a,a ; 0 bits are sent with $20
.bitSet
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	ld a,b
	cp a,SGB_PACKET_SIZE
	jr nz,.nextByte

	; write the first bit of joypad mask with 10 -> 20 -> 30
	ld a,$10
	ldh [rP1],a
	ld a,$20
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a

	; write the next 7 bits and bytes
	dec b
	ld d,8
	ld a,[hli]
	ld e,a
	rr e
	dec d
	jr .sendBit

.nextByte
	dec b
	jr nz,.sendByte

	; Packets are terminated by a "STOP" 0 bit
	ld a,$20
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

SendPacket00To10:
	; Packet transmission begins by sending $00 then $30
	xor a
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$10 ; 1 bits are sent with $10
	rr e ; Rotate e and get its lower bit, two birds in one stone!
	jr c,.bitSet
	add a,a ; 0 bits are sent with $20
.bitSet
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	ld a,b
	cp a,SGB_PACKET_SIZE
	jr nz,.nextByte

	; write the first bit of joypad mask with 00 -> 10 -> 30
	xor a
	ldh [rP1],a
	ld a,$10
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a

	; write the next 7 bits and bytes
	dec b
	ld d,8
	ld a,[hli]
	ld e,a
	rr e
	dec d
	jr .sendBit

.nextByte
	dec b
	jr nz,.sendByte

	; Packets are terminated by a "STOP" 0 bit
	ld a,$20
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

SendPacket00To20:
	; Packet transmission begins by sending $00 then $30
	xor a
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$10 ; 1 bits are sent with $10
	rr e ; Rotate e and get its lower bit, two birds in one stone!
	jr c,.bitSet
	add a,a ; 0 bits are sent with $20
.bitSet
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	ld a,b
	cp a,SGB_PACKET_SIZE
	jr nz,.nextByte

	; write the first bit of joypad mask with 00 -> 20 -> 30
	xor a
	ldh [rP1],a
	ld a,$20
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a

	; write the next 7 bits and bytes
	dec b
	ld d,8
	ld a,[hli]
	ld e,a
	rr e
	dec d
	jr .sendBit

.nextByte
	dec b
	jr nz,.sendByte

	; Packets are terminated by a "STOP" 0 bit
	ld a,$20
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

SendPacket20To00:
	; Packet transmission begins by sending $00 then $30
	xor a
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$10 ; 1 bits are sent with $10
	rr e ; Rotate e and get its lower bit, two birds in one stone!
	jr c,.bitSet
	add a,a ; 0 bits are sent with $20
.bitSet
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	ld a,b
	cp a,SGB_PACKET_SIZE
	jr nz,.nextByte

	; write the first bit of joypad mask with 20 -> 00 -> 30
	ld a,$20
	ldh [rP1],a
	xor a
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a

	; write the next 7 bits and bytes
	dec b
	ld d,8
	ld a,[hli]
	ld e,a
	rr e
	dec d
	jr .sendBit

.nextByte
	dec b
	jr nz,.sendByte

	; Packets are terminated by a "STOP" 0 bit
	ld a,$20
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

SendPacket10To00:
	; Packet transmission begins by sending $00 then $30
	xor a
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$10 ; 1 bits are sent with $10
	rr e ; Rotate e and get its lower bit, two birds in one stone!
	jr c,.bitSet
	add a,a ; 0 bits are sent with $20
.bitSet
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	ld a,b
	cp a,SGB_PACKET_SIZE
	jr nz,.nextByte

	; write the first bit of joypad mask with 00 -> 10 -> 30
	ld a,$10
	ldh [rP1],a
	xor a
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a

	; write the next 7 bits and bytes
	dec b
	ld d,8
	ld a,[hli]
	ld e,a
	rr e
	dec d
	jr .sendBit

.nextByte
	dec b
	jr nz,.sendByte

	; Packets are terminated by a "STOP" 0 bit
	ld a,$20
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

SendPacketShortStart:
	; Packet transmission normally begins by sending $00 then $30
	; Try omitting that $30 write
	xor a
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$10 ; 1 bits are sent with $10
	rr e ; Rotate d and get its lower bit, two birds in one stone!
	jr c,.bitSet
	add a,a ; 0 bits are sent with $20
.bitSet
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	dec b
	jr nz,.sendByte

	; Packets are terminated by a "STOP" 0 bit
	ld a,$20
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

SendPacketCorruptStart10:
	; Packet transmission normally begins by sending $00 then $30
	; Try inserting a $10 write in-between
	xor a
	ldh [rP1],a
	ld a,$10
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$10 ; 1 bits are sent with $10
	rr e ; Rotate d and get its lower bit, two birds in one stone!
	jr c,.bitSet
	add a,a ; 0 bits are sent with $20
.bitSet
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	dec b
	jr nz,.sendByte

	; Packets are terminated by a "STOP" 0 bit
	ld a,$20
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

SendPacketCorruptStart20:
	; Packet transmission normally begins by sending $00 then $30
	; Try inserting a $20 write in-between
	xor a
	ldh [rP1],a
	ld a,$20
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a

	ld b,SGB_PACKET_SIZE
.sendByte
	ld d,8 ; 8 bits in a byte
	ld a,[hli] ; Read byte to send
	ld e,a

.sendBit
	ld a,$10 ; 1 bits are sent with $10
	rr e ; Rotate d and get its lower bit, two birds in one stone!
	jr c,.bitSet
	add a,a ; 0 bits are sent with $20
.bitSet
	ldh [rP1],a
	ld a,$30 ; Terminate pulse
	ldh [rP1],a
	dec d
	jr nz,.sendBit

	dec b
	jr nz,.sendByte

	; Packets are terminated by a "STOP" 0 bit
	ld a,$20
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ret

GetPlayerCount:
.loop
	xor a
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ldh a,[rP1]
	and a,$0F
	sub a,$0F
	jr nz,.loop
	ld b,$00
.loop2
	inc b
	xor a
	ldh [rP1],a
	ld a,$30
	ldh [rP1],a
	ldh a,[rP1]
	and a,$0F
	sub a,$0F
	jr nz,.loop2
	ld a,b
	ret

SECTION "Test Output", WRAM0
wTestOutput::
	ds TestOutputLength
