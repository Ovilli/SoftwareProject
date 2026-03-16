extends Node

const DICE_BLACK = preload("uid://ca35rikf3jygt")
const DICE_BLACK_KING = preload("uid://cetr5sbfhrby0")
const DICE = preload("uid://c7afdlm1rpk1o")
const DICE_KING = preload("uid://cgbm78yds67ov")
const DICE_MODEL = preload("uid://cejfohddoqyog")
const BLACK_DICE_MODEL = preload("uid://cejfohddoqyog")
const DICE_BLACK_LIGHTBLUE_MODEL = preload("uid://dnyub5cgey0qk")
const DICE_BLACK_LIGHTGREEN_MODEL = preload("uid://bqbf2jxc8468e")
const DICE_BLACK_PINK_MODEL = preload("uid://c37t0le60i4jb")
const DICE_BLACK_MODEL = preload("uid://7tuwyx7gm6pw")
const DICE_BLACK_YELLOW_MODEL = preload("uid://boentj700xgy2")
const DICE_LIGHTBLUE_MODEL = preload("uid://bqwc105m4b2fh")
const DICE_LIGHTGREEN_MODEL = preload("uid://c8y6wrccgmrw4")
const DICE_PINK_MODEL = preload("uid://d3uhc45tkkhcc")
const DICE_RED_MODEL = preload("uid://di65dbo03s1on")
const DICE_YELLOW_MODEL = preload("uid://c7d53i06rfxc8")
const KING_BLACK_LIGHTBLUE_MODEL = preload("uid://dpm8nyjabso7h")
const KING_BLACK_LIGHTGREEN_MODEL = preload("uid://bm5mchnsf5gep")
const KING_BLACK_PINK_MODEL = preload("uid://d3gi0etfencnl")
const KING_BLACK_RED_MODEL = preload("uid://7yoy0o0db58t")
const KING_BLACK_YELLOW_MODEL = preload("uid://d2bchlki40gop")
const KING_GREEN_MODEL = preload("uid://djbybqi3v0d8i")
const KING_LIGHTBLUE_MODEL = preload("uid://dq071qx2pb84g")
const KING_PINK_MODEL = preload("uid://cqiidgt8b0pia")
const KING_RED_MODEL = preload("uid://c4p2gv4byrtl0")
const KING_YELLOW_MODEL = preload("uid://cc6sccdshimnu")

# Pivot/Dice
const SKIN_MAP = {
	0: [null,                  null,                  null,                        null                  ],
	1: [DICE_PINK_MODEL,       KING_PINK_MODEL,       DICE_BLACK_PINK_MODEL,       KING_BLACK_PINK_MODEL ],
	2: [DICE_LIGHTGREEN_MODEL, KING_GREEN_MODEL,      DICE_BLACK_LIGHTGREEN_MODEL, KING_BLACK_LIGHTGREEN_MODEL],
	3: [DICE_YELLOW_MODEL,     KING_YELLOW_MODEL,     DICE_BLACK_YELLOW_MODEL,     KING_BLACK_YELLOW_MODEL],
	4: [DICE_LIGHTBLUE_MODEL,  KING_LIGHTBLUE_MODEL,  DICE_BLACK_LIGHTBLUE_MODEL,  KING_BLACK_LIGHTBLUE_MODEL],
	5: [DICE_RED_MODEL,        KING_RED_MODEL,        DICE_BLACK_MODEL,            KING_BLACK_RED_MODEL  ],
}

func get_skin_mesh(piece_id: int) -> ArrayMesh:
	var skins = SKIN_MAP.get(Globals.equipped_skin, SKIN_MAP[0])
	if piece_id > 0 and piece_id < 7:
		return skins[0]
	elif piece_id == 10:
		return skins[1]
	elif piece_id < 0 and piece_id > -7:
		return skins[2]
	elif piece_id == -10:
		return skins[3]
	return null
