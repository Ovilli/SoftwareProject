extends Control

enum SKINS { DEFAULT, PINK, GREEN, YELLOW, BLUE, RED, COMMING_SOON }

@onready var skin_layer: CanvasLayer = $SkinLayer
@onready var skins: ItemList = $SkinLayer/Skins
@onready var skin_texture: TextureRect = $SkinLayer/SkinTexure
@onready var equip_unequip: Button = $SkinLayer/Equip_Uneqip
@onready var text_btn: Label = $SkinLayer/TextBtn

const SKIN_BASE_PATH = "res://assets/texture/skins/"
const SKIN_DATA = {
	SKINS.DEFAULT:     { "name": "Default",      "texture": "DEFAULT.png" },
	SKINS.PINK:        { "name": "Pink",          "texture": "PINK.png"    },
	SKINS.GREEN:       { "name": "Green",         "texture": "GREEN.png"   },
	SKINS.YELLOW:      { "name": "Yellow",        "texture": "YELLOW.png"  },
	SKINS.BLUE:        { "name": "Blue",          "texture": "BLUE.png"    },
	SKINS.RED:         { "name": "Red",           "texture": "RED.png"     },
	SKINS.COMMING_SOON:{ "name": "COMMING SOON",  "texture": "DEFAULT.png" }
}

var selected_skin: SKINS = SKINS.DEFAULT

func _ready() -> void:
	populate_skin_list()
	skins.item_selected.connect(on_skin_selected)
	equip_unequip.pressed.connect(on_equip_pressed)
	skins.select(Globals.equipped_skin)
	on_skin_selected(Globals.equipped_skin)

func _process(_delta) -> void:
	if Windowmng.is_open(Windowmng.Screen.SKINS):
		skin_layer.show()
	else:
		skin_layer.hide()

func populate_skin_list() -> void:
	skins.clear()
	for skin_id in SKIN_DATA:
		skins.add_item(SKIN_DATA[skin_id]["name"])

func on_skin_selected(index: int) -> void:
	selected_skin = index as SKINS
	if not SKIN_DATA.has(selected_skin):
		return
	var texture_path = SKIN_BASE_PATH + SKIN_DATA[selected_skin]["texture"]
	skin_texture.texture = load(texture_path) if ResourceLoader.exists(texture_path) else null
	refresh_equip_button()

func on_equip_pressed() -> void:
	Globals.equipped_skin = SKINS.DEFAULT if Globals.equipped_skin == selected_skin else selected_skin
	refresh_equip_button()

func refresh_equip_button() -> void:
	var is_equipped = Globals.equipped_skin == selected_skin
	text_btn.text = "Equipped" if is_equipped else "Not equipped"
	equip_unequip.text = "Unequip" if is_equipped else "Equip"



func _on_refresh_pressed() -> void:
	on_skin_selected(selected_skin)


func _on_exit_pressed() -> void:
	Windowmng.open(Windowmng.Screen.MAIN_MENU)
