CeruleanGym_Script:
	call EnableAutoTextBoxDrawing
	ld hl, CeruleanGymTrainerHeaders
	ld de, CeruleanGym_ScriptPointers
	ld a, [wCeruleanGymCurScript]
	call ExecuteCurMapScriptInTable
	ld [wCeruleanGymCurScript], a
	ret

CeruleanGymResetScripts:
	xor a ; SCRIPT_CERULEANGYM_DEFAULT
	ld [wJoyIgnore], a
	ld [wCeruleanGymCurScript], a
	ld [wCurMapScript], a
	ret

CeruleanGym_ScriptPointers:
	def_script_pointers
	dw_const CheckFightingMapTrainers,              SCRIPT_CERULEANGYM_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_CERULEANGYM_START_BATTLE
	dw_const EndTrainerBattle,                      SCRIPT_CERULEANGYM_END_BATTLE
	dw_const CeruleanGymMistyPostBattleScript,      SCRIPT_CERULEANGYM_MISTY_POST_BATTLE

CeruleanGymMistyPostBattleScript:
	ld a, [wIsInBattle]
	cp $ff
	jp z, CeruleanGymResetScripts
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a

CeruleanGymReceiveTM11:
	ld a, TEXT_CERULEANGYM_MISTY_CASCADE_BADGE_INFO
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_BEAT_MISTY
	lb bc, TM_MISTY, 1
	call GiveItem
	jr nc, .BagFull
	ld a, TEXT_CERULEANGYM_MISTY_RECEIVED_TM11
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_GOT_TM11
	jr .gymVictory
.BagFull
	ld a, TEXT_CERULEANGYM_MISTY_TM11_NO_ROOM
	ldh [hTextID], a
	call DisplayTextID
.gymVictory
	ld hl, wObtainedBadges
	set BIT_CASCADEBADGE, [hl]
	ld hl, wBeatGymFlags
	set BIT_CASCADEBADGE, [hl]

	; deactivate gym trainers
	SetEvents EVENT_BEAT_CERULEAN_GYM_TRAINER_0, EVENT_BEAT_CERULEAN_GYM_TRAINER_1

	jp CeruleanGymResetScripts

CeruleanGym_TextPointers:
	def_text_pointers
	dw_const CeruleanGymMistyText,                 TEXT_CERULEANGYM_MISTY
	dw_const CeruleanGymCooltrainerFText,          TEXT_CERULEANGYM_COOLTRAINER_F
	dw_const CeruleanGymSwimmerText,               TEXT_CERULEANGYM_SWIMMER
	dw_const CeruleanGymGymGuideText,              TEXT_CERULEANGYM_GYM_GUIDE
	dw_const CeruleanGymMistyCascadeBadgeInfoText, TEXT_CERULEANGYM_MISTY_CASCADE_BADGE_INFO
	dw_const CeruleanGymMistyReceivedTM11Text,     TEXT_CERULEANGYM_MISTY_RECEIVED_TM11
	dw_const CeruleanGymMistyTM11NoRoomText,       TEXT_CERULEANGYM_MISTY_TM11_NO_ROOM

CeruleanGymTrainerHeaders:
	def_trainers 2
CeruleanGymTrainerHeader0:
	trainer EVENT_BEAT_CERULEAN_GYM_TRAINER_0, 3, CeruleanGymBattleText1, CeruleanGymEndBattleText1, CeruleanGymAfterBattleText1
CeruleanGymTrainerHeader1:
	trainer EVENT_BEAT_CERULEAN_GYM_TRAINER_1, 3, CeruleanGymBattleText2, CeruleanGymEndBattleText2, CeruleanGymAfterBattleText2
	db -1 ; end

CeruleanGymMistyText:
	text_asm
	CheckEvent EVENT_BEAT_MISTY
	jr z, .beforeBeat
	CheckEventReuseA EVENT_GOT_TM11
	jr nz, .afterBeat
	call z, CeruleanGymReceiveTM11
	call DisableWaitingAfterTextDisplay
	jr .done
.afterBeat
	ld hl, .TM11ExplanationText
	rst _PrintText
	jr .done
.beforeBeat
	ld hl, .PreBattleText
	rst _PrintText
	ld hl, wStatusFlags3
	set BIT_TALKED_TO_TRAINER, [hl]
	set BIT_PRINT_END_BATTLE_TEXT, [hl]
	ld hl, CeruleanGymMistyReceivedCascadeBadgeText
	ld de, CeruleanGymMistyReceivedCascadeBadgeText
	call SaveEndBattleTextPointers
	ldh a, [hSpriteIndex]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	ld a, $2
	ld [wGymLeaderNo], a
	xor a
	ldh [hJoyHeld], a
	ld a, SCRIPT_CERULEANGYM_MISTY_POST_BATTLE
	ld [wCeruleanGymCurScript], a
.done
	rst TextScriptEnd

.PreBattleText:
	text_far _CeruleanGymMistyPreBattleText
	text_end

.TM11ExplanationText:
	text_far _CeruleanGymMistyTM11ExplanationText
	text_end

CeruleanGymMistyCascadeBadgeInfoText:
	text_far _CeruleanGymMistyCascadeBadgeInfoText
	text_end

CeruleanGymMistyReceivedTM11Text:
	text_far _CeruleanGymMistyReceivedTM11Text
	sound_get_item_1
	text_end

CeruleanGymMistyTM11NoRoomText:
	text_far _CeruleanGymMistyTM11NoRoomText
	text_end

CeruleanGymMistyReceivedCascadeBadgeText:
	text_far _CeruleanGymMistyReceivedCascadeBadgeText
	sound_get_key_item ; actually plays the second channel of SFX_BALL_POOF due to the wrong music bank being loaded
	text_promptbutton
	text_end

CeruleanGymCooltrainerFText:
	text_asm
	ld hl, CeruleanGymTrainerHeader0
	call TalkToTrainer
	rst TextScriptEnd

CeruleanGymBattleText1:
	text_far _CeruleanGymBattleText1
	text_end

CeruleanGymEndBattleText1:
	text_far _CeruleanGymEndBattleText1
	text_end

CeruleanGymAfterBattleText1:
	text_far _CeruleanGymAfterBattleText1
	text_end

CeruleanGymSwimmerText:
	text_asm
	ld hl, CeruleanGymTrainerHeader1
	call TalkToTrainer
	rst TextScriptEnd

CeruleanGymBattleText2:
	text_far _CeruleanGymBattleText2
	text_end

CeruleanGymEndBattleText2:
	text_far _CeruleanGymEndBattleText2
	text_end

CeruleanGymAfterBattleText2:
	text_far _CeruleanGymAfterBattleText2
	text_end

CeruleanGymGymGuideText: ; PureRGBnote: ADDED: gym guide gives you apex chips after beating the leader
	text_asm
	CheckEvent EVENT_BEAT_MISTY
	jr nz, .afterBeat
	ld hl, CeruleanGymChampInMakingText
	rst _PrintText
	rst TextScriptEnd
.afterBeat
	CheckEvent EVENT_GOT_PEWTER_APEX_CHIPS ; have to hear about apex chips to receive them after that
	jr z, .donePost
	ld hl, CeruleanGymBeatMistyTextPrompt
	rst _PrintText
	CheckEvent EVENT_GOT_CERULEAN_APEX_CHIPS
	jr nz, .alreadyApexChips
.giveApexChips
	ld hl, GymGuideMoreApexChipText2
	rst _PrintText
	lb bc, APEX_CHIP, 2
	call GiveItem
	jr nc, .BagFull
	ld hl, ReceivedApexChipsText2
	rst _PrintText
	ld hl, CeruleanGymGuideApexChipWaterText
	rst _PrintText
	SetEvent EVENT_GOT_CERULEAN_APEX_CHIPS
.alreadyApexChips
	ld hl, AlreadyReceivedApexChipsText2
	rst _PrintText
	rst TextScriptEnd
.BagFull
	ld hl, ApexNoRoomText2
	rst _PrintText
	rst TextScriptEnd
.donePost
	ld hl, CeruleanGymBeatMistyText
	rst _PrintText
	rst TextScriptEnd


ReceivedApexChipsText2:
	text_far _ReceivedApexChipsText
	sound_get_item_1
	text_end

ApexNoRoomText2:
	text_far _PewterGymTM34NoRoomText
	text_end

GymGuideMoreApexChipText2:
	text_far _GymGuideMoreApexChipText
	text_end

AlreadyReceivedApexChipsText2:
	text_far _AlreadyReceivedApexChipsText
	text_end

CeruleanGymChampInMakingText:
	text_far _CeruleanGymGymGuideChampInMakingText
	text_end

CeruleanGymBeatMistyTextPrompt:
	text_far _CeruleanGymGymGuideBeatMistyText
	text_promptbutton
	text_end

CeruleanGymBeatMistyText:
	text_far _CeruleanGymGymGuideBeatMistyText
	text_end

ReceivedApexChipsText::
	text_far _ReceivedApexChipsText
	sound_get_item_1
	text_end

CeruleanGymGuideApexChipWaterText:
	text_far _CeruleanGymGuideApexChipWaterText
	text_end