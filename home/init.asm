SoftReset::
	call StopAllSounds
	call GBPalWhiteOut
	ld c, 32
	rst _DelayFrames
	; fallthrough

Init::
;  Program init.

; * LCD enabled
; * Window tile map at $9C00
; * Window display enabled
; * BG and window tile data at $8800
; * BG tile map at $9800
; * 8x8 OBJ size
; * OBJ display enabled
; * BG display enabled
DEF rLCDC_DEFAULT EQU (1 << rLCDC_ENABLE) | (1 << rLCDC_WINDOW_TILEMAP) | (1 << rLCDC_WINDOW_ENABLE) | (1 << rLCDC_SPRITES_ENABLE) | (1 << rLCDC_BG_PRIORITY)

	di

	xor a
	ldh [rIF], a
	ldh [rIE], a
	ldh [rSCX], a
	ldh [rSCY], a
	ldh [rSB], a
	ldh [rSC], a
	ldh [rWX], a
	ldh [rWY], a
	ldh [rTMA], a
	ldh [rTAC], a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a

	ld a, 1 << rLCDC_ENABLE
	ldh [rLCDC], a
	call DisableLCD

	ld sp, wStack

	ld hl, STARTOF(WRAM0)
	; PureRGBnote: WRAMX is the interchangeable second wram set on GBC. If we add it with WRAM0 it will have the original size of WRAM of the game.
	; on PureRGB another wram bank is used on GBC for the GBC fade animation function's storage so WRAMX was introduced to the code.
	ld bc, SIZEOF(WRAM0) + SIZEOF(WRAMX)
.loop
; PureRGBnote: OPTIMIZED
	xor a
	ld [hli], a
	;ld [hl], 0
	;inc hl
	dec bc
	ld a, b
	or c
	jr nz, .loop

	call ClearVram

	ld hl, STARTOF(HRAM)
	ld bc, SIZEOF(HRAM) - 1 ; shinpokerednote: gbcnote: the -1 means don't clear hGBC
	call FillMemory

	call ClearSprites

	ld a, BANK(WriteDMACodeToHRAM)
	call SetCurBank
	call WriteDMACodeToHRAM

	xor a
	ldh [hTileAnimations], a
	ldh [rSTAT], a
	ldh [hSCX], a
	ldh [hSCY], a
	ldh [rIF], a
	ld a, 1 << VBLANK + 1 << TIMER + 1 << SERIAL
	ldh [rIE], a

	ld a, 144 ; move the window off-screen
	ldh [hWY], a
	ldh [rWY], a
	ld a, 7
	ldh [rWX], a

	ld a, CONNECTION_NOT_ESTABLISHED
	ldh [hSerialConnectionStatus], a

	ld h, HIGH(vBGMap0)
	call ClearBgMap
	ld h, HIGH(vBGMap1)
	call ClearBgMap

	ld a, rLCDC_DEFAULT
	ldh [rLCDC], a
	ld a, 16
	ldh [hSoftReset], a
	call StopAllSounds

	ei

;;;;;;;;;; PureRGBnote: ADDED: load options configuration from SRAM on boot of the game so we can respect the color/sprite settings.
	callfar CopyOptionsFromSRAM
;;;;;;;;;;

	predef LoadSGB

	ld a, BANK(SFX_Shooting_Star)
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	ld a, $9c
	ldh [hAutoBGTransferDest + 1], a
	xor a
	ldh [hAutoBGTransferDest], a
	dec a
	ld [wUpdateSpritesEnabled], a

IF DEF(_DEBUG)
	;jpfar DebugMenu ; PureRGBnote: ADDED: uncomment this to instantly enter debug mode on starting the game in the debug rom
ENDC
	predef PlayIntro 

	call DisableLCD
	call ClearVram
	call GBPalNormal
	call ClearSprites
	ld a, rLCDC_DEFAULT
	ldh [rLCDC], a

	jp PrepareTitleScreen

ClearVram::
	ld hl, STARTOF(VRAM)
	ld bc, SIZEOF(VRAM)
	xor a
	jp FillMemory


StopAllSounds::
	ld a, BANK("Audio Engine 1")
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	xor a
	ld [wAudioFadeOutControl], a
	ld [wNewSoundID], a
	ld [wLastMusicSoundID], a
	dec a
	jp StopAllMusic
