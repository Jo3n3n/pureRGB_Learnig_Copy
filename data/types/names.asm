TypeNames:
	table_width 2, TypeNames

	dw .Normal
	dw .Fighting
	dw .Flying
	dw .Poison
	dw .Ground
	dw .Rock
	dw .Typeless
	dw .Bug
	dw .Ghost
	dw .Crystal
	dw .Ground ; bonemerang type

REPT UNUSED_TYPES_END - UNUSED_TYPES
	dw .Normal
ENDR
	dw .Tri
	dw .Floating
	dw .Magma
	dw .Fire
	dw .Water
	dw .Grass
	dw .Electric
	dw .Psychic
	dw .Ice
	dw .Dragon

	assert_table_length NUM_TYPES

.Normal:   db "NORMAL@"
.Fighting: db "KAMPF@"
.Flying:   db "FLUG@"
.Poison:   db "GIFT@"
.Fire:     db "FEUER@"
.Water:    db "WASSER@"
.Grass:    db "PFLANZE@"
.Electric: db "ELEKTRO@"
.Psychic:  db "PSYCHO@"
.Ice:      db "EIS@"
.Ground:   db "BODEN@"
.Rock:     db "GESTEIN@"
.Typeless: db "KEIN@"
.Bug:      db "KÄFER@"
.Ghost:    db "GEIST@"
.Dragon:   db "DRACHE@"
.Tri:      db "TRI@"
.Crystal:  db "KRYSTAL@"
.Floating: db "SCHWEBEND@"
.Magma:    db "MAGMA@"
