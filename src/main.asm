; main area
INCLUDE "hardware.inc"

tileset_start EQU $9000

SECTION "headers", ROM0[$100]
EntryPoint:
  di
  jp main

REPT $150 - $104
    db 0
ENDR

SECTION "Game code", ROM0
main:
  call shut_off_display
  call init_font
  ld bc, hello_world_str
  call print_bc
  call final_init
.lockup
  halt
  halt
  jp .lockup

SECTION "print bc", ROM0
print_bc:
  ld hl, _SCRN0
.loop
  ld a, [bc]
  or a
  ret z
  inc bc
  ld [hl+], a
  jp .loop
  ret

SECTION "Finalize initialization", ROM0
final_init:
  ; Background pallete
  ; %11100100 = 11 10 01 00 = 3 2 1 0 
  ; %11011000 = 00 01 10 00 = 0 1 2 3
  ld a, %11100100
  ld [rBGP], a 

  ; Background scroll registers
  xor a ; ld a, 0
  ld [rSCY], a
  ld [rSCX], a

  ; Shut sound down
  ld [rNR52], a

  ; Turn screen on, display background
  ; BG8800: $9000-$97F0 $00-$7F, $8800-$8FF0 $80-$FF ($-80, $-1)
  ; WIN9800: _SCRN0-_SCRN0+$400 is background
  ld a, LCDCF_ON | LCDCF_BG8800 | LCDCF_WIN9800 | LCDCF_BGON
  ld [rLCDC], a
  ret

SECTION "Initialize display", ROM0
shut_off_display:
.waitVBlank
  ld a, [rLY]
  cp $90 ; Check if the LCD is past VBlank
  jr c, .waitVBlank

  xor a ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
  ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really.
  ret

SECTION "Initialize font", ROM0
init_font:
  ld hl, tileset_start
  ld de, FontTiles
  ld bc, FontTilesEnd - FontTiles
.copyFont
  ld a, [de] ; Grab 1 byte from the source
  ld [hl+], a ; Place it at the destination, incrementing hl
  inc de ; Move to next byte
  dec bc ; Decrement count
  ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
  or c
  jr nz, .copyFont
  ret


CHARMAP "H", 1
CHARMAP "e", 2
CHARMAP "l", 3
CHARMAP "o", 4
CHARMAP "W", 5
CHARMAP "r", 6
CHARMAP "d", 7
CHARMAP "!", 8
CHARMAP " ", 9

SECTION "Strings", ROM0
hello_world_str:
  db "Hello World!", $0

SECTION "Font", ROM0
FontTiles:
; $0
DW `00000000
DW `00000000
DW `00000000
DW `00000000
DW `00000000
DW `00000000
DW `00000000
DW `00000000

; 'H'
DW `00000000
DW `03000030
DW `03000030
DW `03333330
DW `03000030
DW `03000030
DW `03000030
DW `00000000

; 'e'
DW `00000000
DW `00000000
DW `00333000
DW `03000300
DW `03333000
DW `03000000
DW `00333300
DW `00000000

; 'l'
DW `00000000
DW `00030000
DW `00030000
DW `00030000
DW `00030000
DW `00030000
DW `00003300
DW `00000000

; 'o'
DW `00000000
DW `00000000
DW `00333000
DW `03000300
DW `03000300
DW `03000300
DW `00333000
DW `00000000

; 'W'
DW `00000000
DW `03000030
DW `03000030
DW `03000030
DW `03000030
DW `03033030
DW `00300300
DW `00000000

; 'r'
DW `00000000
DW `00000000
DW `00033300
DW `00300000
DW `00300000
DW `00300000
DW `00300000
DW `00000000

; 'd'
DW `00000000
DW `00000300
DW `00000300
DW `00333300
DW `03000300
DW `03000300
DW `00333300
DW `00000000

; '!'
DW `00000000
DW `00030000
DW `00030000
DW `00030000
DW `00030000
DW `00000000
DW `00030000
DW `00000000

; ' '
DW `00000000
DW `00000000
DW `00000000
DW `00000000
DW `00000000
DW `00000000
DW `00000000
DW `00000000

FontTilesEnd: