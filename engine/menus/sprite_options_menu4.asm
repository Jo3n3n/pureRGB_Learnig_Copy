; PureRGBnote: ADDED: one of the new pages in the options menu. This one's one of the two pages for options related to game sprites.

DEF PAGE7_OPTION1_LEFT_XPOS EQU 13
DEF PAGE7_OPTION1_RIGHT_XPOS EQU 16
DEF PAGE7_OPTION2_LEFT_XPOS EQU 13
DEF PAGE7_OPTION2_RIGHT_XPOS EQU 16
DEF PAGE7_OPTION3_LEFT_XPOS EQU 13
DEF PAGE7_OPTION3_RIGHT_XPOS EQU 16
DEF PAGE7_OPTION4_LEFT_XPOS EQU 13
DEF PAGE7_OPTION4_RIGHT_XPOS EQU 16
DEF PAGE7_OPTION5_LEFT_XPOS EQU 13
DEF PAGE7_OPTION5_RIGHT_XPOS EQU 16
DEF PAGE7_OPTION6_LEFT_XPOS EQU 13
DEF PAGE7_OPTION6_RIGHT_XPOS EQU 16

DEF PAGE7_OPTION1_BIT EQU BIT_KADABRA_SPRITE
DEF PAGE7_OPTION2_BIT EQU BIT_TENTACRUEL_SPRITE
DEF PAGE7_OPTION3_BIT EQU BIT_GRAVELER_SPRITE
DEF PAGE7_OPTION4_BIT EQU BIT_MACHOP_SPRITE
DEF PAGE7_OPTION5_BIT EQU BIT_PINSIR_SPRITE
DEF PAGE7_OPTION6_BIT EQU BIT_ZAPDOS_SPRITE

SpritesOptionText4:
	db   "SPRITES 4"
	next " KADABRA:    RB RG"
	next " TENTACRUEL: RB RG"
	next " GRAVELER:   RB RG"
	next " MACHOP:     RB RG"
	next " PINSIR:     RB RG"
	next " ZAPDOS:     RB RG@"

SpriteOption4PageText:
	db "7/7@"

DisplaySpriteOptions4:
	hlcoord 0, 0
	ld b, 14
	ld c, 18
	call TextBoxBorder
	hlcoord 1, 1
	ld de, SpritesOptionText4
	call PlaceString
	hlcoord 2, 16
	ld de, OptionsNextBackText
	call PlaceString
	hlcoord 16, 16
	ld de, SpriteOption4PageText
	call PlaceString
	xor a
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	inc a
	ld [wLetterPrintingDelayFlags], a
	ld a, [wOptionsCancelCursorX]
	and a
	jr nz, .cancelXValue
	ld a, 1
.cancelXValue
	ld [wOptionsCancelCursorX], a
	ld [wTopMenuItemX], a ; next page coordinate
	push af
	ld a, 16 ; next page coordinate
	ld [wTopMenuItemY], a
	call SetCursorPositionsFromSpriteOptions4
	pop af
	cp 7
	jr nz, .doneLoad
	hlcoord 1, 16
	ld [hl], " "
.doneLoad
	ld a, $01
	ldh [hAutoBGTransferEnabled], a ; enable auto background transfer
	call Delay3
.loop
	call PlaceMenuCursor
	call SetSpriteOptionsFromCursorPositions4
.getJoypadStateLoop
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	ld b, a
	and A_BUTTON | B_BUTTON | START | D_RIGHT | D_LEFT | D_UP | D_DOWN ; any key besides select pressed?
	jr z, .getJoypadStateLoop
	bit BIT_B_BUTTON, b
	jr nz, .exitMenu
	bit BIT_START, b
	jr nz, .exitMenu
	bit BIT_A_BUTTON, b
	jr z, .checkDirectionKeys
	ld a, [wTopMenuItemY]
	cp 16 ; is the cursor on the cancel row?
	jr z, .cancelMore
	jr .loop
.cancelMore
	ld a, SFX_PRESS_AB
	call PlaySound
	call ClearScreen
	ld a, [wTopMenuItemX]
	cp 7 ; is the cursor on "BACK">
	jr z, .back
	jp DisplayOptionMenu
.back
	jp DisplaySpriteOptions3
.exitMenu
	ld a, SFX_PRESS_AB
	call PlaySound
	ret
.checkDirectionKeys
	ld a, [wTopMenuItemY]
	bit BIT_D_DOWN, b
	jr nz, .downPressed
	bit BIT_D_UP, b
	jr nz, .upPressed
	call leftRightPressed4
	jp .loop
.downPressed
	cp 16
	ld b, -13 ;b = how far vertically the cursor will go compared to its current location
	ld hl, wOptionsPage7Option1CursorX
	jr z, .updateMenuVariables
	ld b, 2
	cp 3
	inc hl
	jr z, .updateMenuVariables
	cp 5
	inc hl
	jr z, .updateMenuVariables
	cp 7
	inc hl
	jr z, .updateMenuVariables
	cp 9
	inc hl
	jr z, .updateMenuVariables
	cp 11
	inc hl
	jr z, .updateMenuVariables
	ld b, 3
	ld hl, wOptionsCancelCursorX
	jr .updateMenuVariables
.upPressed
	cp 5
	ld b, -2
	ld hl, wOptionsPage7Option1CursorX
	jr z, .updateMenuVariables
	cp 7
	inc hl
	jr z, .updateMenuVariables
	cp 9
	inc hl
	jr z, .updateMenuVariables
	cp 11
	inc hl
	jr z, .updateMenuVariables
	cp 13
	inc hl
	jr z, .updateMenuVariables
	cp 16
	ld b, -3
	inc hl
	jr z, .updateMenuVariables
	ld b, 13
	ld hl, wOptionsCancelCursorX
.updateMenuVariables
	add b
	ld [wTopMenuItemY], a
	ld a, [hl]
	ld [wTopMenuItemX], a
	call PlaceUnfilledArrowMenuCursor
	jp .loop


leftRightPressed4:
	cp 3 ; cursor in Back Sprite section?
	jr z, .cursorInOption1
	cp 5 ; cursor in Menu Sprite section?
	jr z, .cursorInOption2
	cp 7 ; cursor in Bulbasaur section?
	jr z, .cursorInOption3
	cp 9 ; cursor in Squirtle section?
	jr z, .cursorInOption4
	cp 11 ; cursor in Blastoise section?
	jr z, .cursorInOption5
	cp 13 ; cursor in Pidgeot section?
	jr z, .cursorInOption6
	cp 16 ; cursor on Cancel?
	jr z, .cursorCancelRow
.cursorInOption1
	ld a, [wOptionsPage7Option1CursorX] ; battle animation cursor X coordinate
	ld b, PAGE7_OPTION1_LEFT_XPOS
	cp PAGE7_OPTION1_RIGHT_XPOS
	jr z, .loadOption1X
	ld b, PAGE7_OPTION1_RIGHT_XPOS
.loadOption1X
	ld a, b
	ld [wOptionsPage7Option1CursorX], a
	jp .eraseOldMenuCursor
.cursorInOption2
	ld a, [wOptionsPage7Option2CursorX] ; battle animation cursor X coordinate
	ld b, PAGE7_OPTION2_LEFT_XPOS
	cp PAGE7_OPTION2_RIGHT_XPOS
	jr z, .loadOption2X
	ld b, PAGE7_OPTION2_RIGHT_XPOS
.loadOption2X
	ld a, b
	ld [wOptionsPage7Option2CursorX], a
	jp .eraseOldMenuCursor
.cursorInOption3
	ld a, [wOptionsPage7Option3CursorX] ; battle animation cursor X coordinate
	ld b, PAGE7_OPTION3_LEFT_XPOS
	cp PAGE7_OPTION3_RIGHT_XPOS
	jr z, .loadOption3X
	ld b, PAGE7_OPTION3_RIGHT_XPOS
.loadOption3X
	ld a, b
	ld [wOptionsPage7Option3CursorX], a
	jp .eraseOldMenuCursor
.cursorInOption4
	ld a, [wOptionsPage7Option4CursorX] ; battle animation cursor X coordinate
	ld b, PAGE7_OPTION4_LEFT_XPOS
	cp PAGE7_OPTION4_RIGHT_XPOS
	jr z, .loadOption4X
	ld b, PAGE7_OPTION4_RIGHT_XPOS
.loadOption4X
	ld a, b
	ld [wOptionsPage7Option4CursorX], a
	jp .eraseOldMenuCursor
.cursorInOption5
	ld a, [wOptionsPage7Option5CursorX] ; battle animation cursor X coordinate
	ld b, PAGE7_OPTION5_LEFT_XPOS
	cp PAGE7_OPTION5_RIGHT_XPOS
	jr z, .loadOption5X
	ld b, PAGE7_OPTION5_RIGHT_XPOS
.loadOption5X
	ld a, b
	ld [wOptionsPage7Option5CursorX], a
	jp .eraseOldMenuCursor
.cursorInOption6
	ld a, [wOptionsPage7Option6CursorX] ; battle animation cursor X coordinate
	ld b, PAGE7_OPTION6_LEFT_XPOS
	cp PAGE7_OPTION6_RIGHT_XPOS
	jr z, .loadOption6X
	ld b, PAGE7_OPTION6_RIGHT_XPOS
.loadOption6X
	ld a, b
	ld [wOptionsPage7Option6CursorX], a
	jp .eraseOldMenuCursor
.cursorCancelRow
	ld a, [wOptionsCancelCursorX] ; battle style cursor X coordinate
	xor 6 ; toggle between 1 and 7
	ld [wOptionsCancelCursorX], a
	jp .eraseOldMenuCursor
.eraseOldMenuCursor
	ld [wTopMenuItemX], a
	call EraseMenuCursor
	ret


; sets the options variable according to the current placement of the menu cursors in the options menu
SetSpriteOptionsFromCursorPositions4:
	ld a, [wSpriteOptions4]
	ld d, a
	ld a, [wOptionsPage7Option1CursorX] ; battle style cursor X coordinate
	cp PAGE7_OPTION1_RIGHT_XPOS 
	jr z, .option1setRight
.option1setLeft
	res PAGE7_OPTION1_BIT, d
	jr .checkOption2
.option1setRight
	set PAGE7_OPTION1_BIT, d
.checkOption2
	ld a, [wOptionsPage7Option2CursorX] ; battle style cursor X coordinate
	cp PAGE7_OPTION2_RIGHT_XPOS 
	jr z, .option2setRight
.option2setLeft
	res PAGE7_OPTION2_BIT, d
	jr .storeOptions
.option2setRight
	set PAGE7_OPTION2_BIT, d
.storeOptions
.checkOption3
	ld a, [wOptionsPage7Option3CursorX] ; battle style cursor X coordinate
	cp PAGE7_OPTION3_RIGHT_XPOS 
	jr z, .option3setRight
.option3setLeft
	res PAGE7_OPTION3_BIT, d
	jr .checkOption4
.option3setRight
	set PAGE7_OPTION3_BIT, d
.checkOption4
	ld a, [wOptionsPage7Option4CursorX] ; battle style cursor X coordinate
	cp PAGE7_OPTION4_RIGHT_XPOS 
	jr z, .option4setRight
.option4setLeft
	res PAGE7_OPTION4_BIT, d
	jr .checkOption5
.option4setRight
	set PAGE7_OPTION4_BIT, d
.checkOption5
	ld a, [wOptionsPage7Option5CursorX] ; battle style cursor X coordinate
	cp PAGE7_OPTION5_RIGHT_XPOS 
	jr z, .option5setRight
.option5setLeft
	res PAGE7_OPTION5_BIT, d
	jr .checkOption6
.option5setRight
	set PAGE7_OPTION5_BIT, d
.checkOption6
	ld a, [wOptionsPage7Option6CursorX] ; battle style cursor X coordinate
	cp PAGE7_OPTION6_RIGHT_XPOS 
	jr z, .option6setRight
.option6setLeft
	res PAGE7_OPTION6_BIT, d
	jr .storeSpriteOptions
.option6setRight
	set PAGE7_OPTION6_BIT, d
.storeSpriteOptions
	ld a, d
	ld [wSpriteOptions4], a
	ret

SetCursorPositionsFromSpriteOptions4:
	ld hl, wSpriteOptions4
	ld a, PAGE7_OPTION1_LEFT_XPOS
	bit PAGE7_OPTION1_BIT, [hl]
	jr z, .storeOption1CursorX
	ld a, PAGE7_OPTION1_RIGHT_XPOS
.storeOption1CursorX
	ld [wOptionsPage7Option1CursorX], a ; Back Sprites Cursor X Coordinate
	hlcoord 0, 3
	call .placeUnfilledRightArrow
.getOption2
	ld a, PAGE7_OPTION2_LEFT_XPOS
	ld hl, wSpriteOptions4
	bit PAGE7_OPTION2_BIT, [hl]
	jr z, .storeOption2CursorX
	ld a, PAGE7_OPTION2_RIGHT_XPOS
.storeOption2CursorX
	ld [wOptionsPage7Option2CursorX], a ; Menu Sprites Cursor X Coordinate
	hlcoord 0, 5
	call .placeUnfilledRightArrow
.getOption3
	ld a, PAGE7_OPTION3_LEFT_XPOS
	ld hl, wSpriteOptions4
	bit PAGE7_OPTION3_BIT, [hl]
	jr z, .storeOption3SpriteCursorX
	ld a, PAGE7_OPTION3_RIGHT_XPOS
.storeOption3SpriteCursorX
	ld [wOptionsPage7Option3CursorX], a ; Back Sprites Cursor X Coordinate
	hlcoord 0, 7
	call .placeUnfilledRightArrow
.getOption4SpriteOption
	ld a, PAGE7_OPTION4_LEFT_XPOS
	ld hl, wSpriteOptions4
	bit PAGE7_OPTION4_BIT, [hl]
	jr z, .storeOption4SpriteCursorX
	ld a, PAGE7_OPTION4_RIGHT_XPOS
.storeOption4SpriteCursorX
	ld [wOptionsPage7Option4CursorX], a ; Back Sprites Cursor X Coordinate
	hlcoord 0, 9
	call .placeUnfilledRightArrow
.getOption5SpriteOption
	ld a, PAGE7_OPTION5_LEFT_XPOS
	ld hl, wSpriteOptions4
	bit PAGE7_OPTION5_BIT, [hl]
	jr z, .storeOption5SpriteCursorX
	ld a, PAGE7_OPTION5_RIGHT_XPOS
.storeOption5SpriteCursorX
	ld [wOptionsPage7Option5CursorX], a ; Back Sprites Cursor X Coordinate
	hlcoord 0, 11
	call .placeUnfilledRightArrow
.getOption6SpriteOption
	ld a, PAGE7_OPTION6_LEFT_XPOS
	ld hl, wSpriteOptions4
	bit PAGE7_OPTION6_BIT, [hl]
	jr z, .storeOption6SpriteCursorX
	ld a, PAGE7_OPTION6_RIGHT_XPOS
.storeOption6SpriteCursorX
	ld [wOptionsPage7Option6CursorX], a ; Back Sprites Cursor X Coordinate
	hlcoord 0, 13
	call .placeUnfilledRightArrow
	; cursor in front of Cancel
	hlcoord 0, 16
	ld a, 1
.placeUnfilledRightArrow
	ld e, a
	ld d, 0
	add hl, de
	ld [hl], "▷"
	ret
