arch gba.thumb

//==============================================================================
// Relocation hacks
//==============================================================================

// Move the weird box font from 0xFCE6C
org $80B3274; dd m2_font_relocate


//==============================================================================
// Font hacks
//==============================================================================

org $8AFED84; incbin m2-mainfont1-empty.bin
org $8B0F424; incbin m2-mainfont2-empty.bin
org $8B13424; incbin m2-mainfont3-empty.bin
org $8B088A4; incbin m2-shifted-cursor.bin

// Greek letters
org $8B1B907; db $8B // alpha
org $8B1B90A; db $8C // beta
org $8B1B90D; db $8D // gamma
org $8B1B910; db $8E // sigma
org $8B1B913; db $8F // omega


//==============================================================================
// VWF hacks
//==============================================================================

// 32- to 16-bit access change for window flags
org $80BE16A; strh r2,[r4,#0]
org $80BE1FA; strh r2,[r6,#0]
org $80BE222; strh r6,[r1,#0]

// PSI class window size
org     $80B7820
mov     r1,#4
mov     r2,#1
mov     r3,#6

//---------------------------------------------------------
// C0A5C hacks (status window)
//---------------------------------------------------------

incsrc m2-status-initial.asm
incsrc m2-status-switch.asm

//---------------------------------------------------------
// BAC18 hacks (status window switching)
//---------------------------------------------------------

org $80BACFC; bl m2_vwf_entries.bac18_redraw_status
org $80BADE6; bl m2_vwf_entries.bac18_redraw_status
org $80BACEE; bl m2_vwf_entries.bac18_clear_psi
org     $80BADC8
bl      m2_vwf_entries.bac18_check_button
b       $80BADD8

//---------------------------------------------------------
// BAEF8 hacks (equip window)
//---------------------------------------------------------

// Erase offense change
define erase_offense "mov r0,#0xC; mov r1,#0xB; mov r2,#4; bl m2_vwf.print_blankstr"
org $80BB216; {erase_offense}
org $80BB38C; {erase_offense}
org $80BB4C6; {erase_offense}
org $80BB5FC; {erase_offense}
org $80BBAAE; {erase_offense}
org $80BBBF6; {erase_offense}
org $80BBD54; {erase_offense}

// Erase defense change
define erase_defense "mov r0,#0xC; mov r1,#0xD; mov r2,#4; bl m2_vwf.print_blankstr"
org $80BB226; {erase_defense}
org $80BBABE; {erase_defense}
org $80BBC06; {erase_defense}
org $80BBD64; {erase_defense}

// Erase offense/defense after changing equipment
org $80BB3E2; bl m2_vwf_entries.baef8_reequip_erase
org $80BB518; bl m2_vwf_entries.baef8_reequip_erase
org $80BBB12; bl m2_vwf_entries.baef8_reequip_erase
org $80BBC70; bl m2_vwf_entries.baef8_reequip_erase

//80B80EE

//---------------------------------------------------------
// C5500 hacks (equip window switching)
//---------------------------------------------------------

// Clear offense/defense changes when moving cursor
org $80C5AA2; bl m2_vwf_entries.c5500_clear_up
org $80C5B12; bl m2_vwf_entries.c5500_clear_down

// Don't draw equip icon
org $80C5A1A; nop
org $80C5A28; nop

//---------------------------------------------------------
// C1FBC hacks (PSI window)
//---------------------------------------------------------

org $80C203E; mov r1,#0x14 // new entry length
org $80C21B4; mov r1,#0x14
org $80C224A; mov r1,#0x14
org $80C229E; mov r1,#0x14

// Draw PSI Rockin
org     $80C2192
mov     r2,r8
str     r2,[sp,#0]
mov     r2,#0xFD
lsl     r2,r2,#1
add     r0,r6,r2
mov     r1,#0x71
mov     r2,#8
bl      m2_vwf.print_string

//---------------------------------------------------------
// C438C hacks (PSI window cursor movement)
//---------------------------------------------------------

org $80C4580; bl m2_vwf_entries.c438c_moveup
org $80C4642; bl m2_vwf_entries.c438c_movedown
org $80C4768; bl m2_vwf_entries.c438c_moveright
org $80C48B2; bl m2_vwf_entries.c438c_moveleft

//---------------------------------------------------------
// PSI target window hacks
//---------------------------------------------------------

// PSI target length hack
org $80B8B12; mov r0,#0x14
org $80C24EE; mov r1,#0x14

// Fix PSI target offset calculation
org $80B8B08
mov     r1,#100
mul     r1,r2
nop
nop

// Make PP cost use correct number values
org     $80CA732
add     r1,#0x60

// Make PP cost use the correct space value if there's only one digit
org     $80CA712
mov     r0,#0x50

//---------------------------------------------------------
// B8BBC hacks (PSI window)
//---------------------------------------------------------

// Redraw main menu when exiting PSI target window
org $80B8E3A; bl m2_vwf_entries.b8bbc_redraw_menu_2to1

// Redraw main menu when entering PSI target window
org $80B8CF8; bl m2_vwf_entries.b8bbc_redraw_menu_13to2 // 1 to 2
org $80B920C; bl m2_vwf_entries.b8bbc_redraw_menu_13to2 // 3 to 2

//---------------------------------------------------------
// C4B2C hacks (Equip window render)
//---------------------------------------------------------

// Start equipment at the 6th tile instead of 5th
org $80C4C96; mov r2,#6 // Weapon
org $80C4D1C; mov r2,#6 // Body
org $80C4DA4; mov r2,#6 // Arms
org $80C4E2C; mov r2,#6 // Other

// Only render (None) if necessary
org     $80C4C0C
bl      m2_vwf_entries.c4b2c_skip_nones
b       $80C4C58

// Don't render equip symbols
org $80C4CD0; nop
org $80C4CDE; nop
org $80C4D58; nop
org $80C4D66; nop
org $80C4DE0; nop
org $80C4DEE; nop
org $80C4E68; nop
org $80C4E76; nop

// Widen the who/where/etc window
org $80B77B4; mov r3,#5
org $80BA9E2; mov r3,#5

//---------------------------------------------------------
// C4B2C hacks (Equip window loop)
//---------------------------------------------------------

org $80C4F80; bl m2_vwf_entries.c4b2c_clear_left
org $80C4F84; bl m2_vwf_entries.c4b2c_clear_right

//---------------------------------------------------------
// C980C hacks (main character printing)
//---------------------------------------------------------

// Reset pixel X during scroll
org $80C9858; bl m2_vwf_entries.c980c_resetx_newline
org $80C9BF0; bl m2_vwf_entries.c980c_resetx_scroll
org $80C9D18; bl m2_vwf_entries.c980c_resetx_newline
org $80CA336; bl m2_vwf_entries.c980c_resetx_newline

// Reset pixel X during a newline
org     $80C9CC4
bl      m2_vwf_entries.c980c_resetx_newline

// Other reset X
org $80C9D62; bl m2_vwf_entries.c980c_resetx_other
org $80C9D76; bl m2_vwf_entries.c980c_resetx_other2
org $80C9EEC; bl m2_vwf_entries.c980c_resetx_other3
org $80C9F34; bl m2_vwf_entries.c980c_resetx_other3
org $80CA204; bl m2_vwf_entries.c980c_resetx_other4
org $80CA274; bl m2_vwf_entries.c980c_resetx_other4
org $80CA30E; bl m2_vwf_entries.c980c_resetx_newline

// Custom codes check
org     $80CA2BC
bl      m2_vwf_entries.c980c_custom_codes

// Reset pixel X when redrawing the window
org     $80CA2E6
bl      m2_vwf_entries.c980c_resetx

// Welding entry
org     $80CA448
bl      m2_vwf_entries.c980c_weld_entry
b       $80CA46C

// Disable X coordinate incrementing
org     $80CA48E
nop

//---------------------------------------------------------
// C8FFC hacks (main string printing)
//---------------------------------------------------------

// Custom codes check
org     $80C90A2
bl      m2_vwf_entries.c8ffc_custom_codes

// Welding entry
org     $80C9114
bl      m2_vwf_entries.c8ffc_weld_entry
b       $80C9144

// Integer-to-char changes
org $80CA67C; mov r3,#0x50 // space
org $80CA69C; mov r2,#0x60 // zero
org $80CA78A; mov r0,#0x60 // zero
org $80CA7AC; mov r2,#0x69 // nine
org $80CA7EC; sub r1,#0xA0

//---------------------------------------------------------
// C87D0 hacks (draw blank window)
//---------------------------------------------------------

org     $80C87DC
bl      m2_vwf_entries.c87d0_clear_entry

//---------------------------------------------------------
// C9634 hacks (string printing)
//---------------------------------------------------------

org     $80C967E
bl      m2_vwf_entries.c9634_resetx

//---------------------------------------------------------
// C96F0 hacks (string printing with highlight)
//---------------------------------------------------------

org     $80C9714
lsl     r3,r3,#1 // change from row coords to tile coords
ldrh    r1,[r0,#0x22]
add     r1,r1,r2
lsl     r1,r1,#3 // r1 = tile_x * 8
ldrh    r2,[r0,#0x24]
add     r2,r2,r3
lsl     r2,r2,#3 // r2 = tile_y * 8
mov     r0,r6
bl      m2_vwf.print_string
mov     r7,r0
b       $80C9788

//---------------------------------------------------------
// CA4BC hacks (scroll text)
//---------------------------------------------------------

org $80CA55E; bl m2_vwf_entries.ca4bc_erase_tile_short
org $80CA60E; bl m2_vwf_entries.ca4bc_copy_tile_up
org $80CA626; bl m2_vwf_entries.ca4bc_erase_tile

//---------------------------------------------------------
// D2E94 hacks (print party character name)
//---------------------------------------------------------

org     $80D2F24
mov     r1,r6
mov     r2,r7
mov     r0,r4
bl      m2_vwf.weld_entry
b       $80D2F52

// Disable X increment
org $80D2F5A; nop

//---------------------------------------------------------
// D30C4 hacks (print number)
//---------------------------------------------------------

org     $80D314A
mov     r0,r5
mov     r1,r7
bl      m2_vwf.weld_entry
b       $80D3178

// Disable X increment
org $80D3180; nop

//---------------------------------------------------------
// D332C hacks (print name)
//---------------------------------------------------------

org     $80D34E8
mov     r0,r5
mov     r1,r4
bl      m2_vwf.weld_entry
b       $80D3514

// Disable X increment
org $80D351A; nop

//---------------------------------------------------------
// D3934 hacks (print PSI name)
//---------------------------------------------------------

org $80D39BA; mov r0,#0x14 // PSI name length

// Weld entry
org     $80D39E2
mov     r0,r4
mov     r1,r5
bl      m2_vwf.weld_entry
b       $80D3A14

// Print a space before the Greek letter
org $80D39D4; bl m2_vwf_entries.d3934_print_space

// Allocate extra space for enemy names
org $80DB04E; add sp,#-0x20
org $80DB058; mov r2,#0x1E
org $80DB08C; mov r2,#0x1A
org $80DB116; mov r1,#0x1E
org $80DB15A; app sp,#0x20

//80DB116: length of name + end code

//==============================================================================
// Data files
//==============================================================================

org $8B2C000

// Box font relocation
m2_font_relocate:
incbin m2-font-relocate.bin

// Co-ordinate table
m2_coord_table:
incbin m2-coord-table.bin

// EB fonts
m2_font_table:
dd     m2_font_main
dd     m2_font_saturn

m2_font_main:
incbin m2-font-main.bin

m2_font_saturn:
incbin m2-font-saturn.bin

// EB font heights
m2_height_table:
db     $02, $02, $01, $00    // last byte for alignment

// EB font widths
m2_widths_table:
dd     m2_widths_main
dd     m2_widths_saturn

m2_widths_main:
incbin m2-widths-main.bin

m2_widths_saturn:
// tbd

m2_bits_to_nybbles:
incbin m2-bits-to-nybbles.bin

m2_nybbles_to_bits:
incbin m2-nybbles-to-bits.bin


//==============================================================================
// Misc
//==============================================================================

org $2027FC0
m2_custom_wram:


//==============================================================================
// Code files
//==============================================================================

org $80FCE6C
incsrc m2-vwf.asm
incsrc m2-vwf-entries.asm
incsrc m2-formatting.asm
incsrc m2-customcodes.asm
