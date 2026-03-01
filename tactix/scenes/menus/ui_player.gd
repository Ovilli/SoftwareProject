extends Control

@onready var moves_left: Label = get_node("CanvasLayer/Label")#$Label 
@onready var layer_dice: CanvasLayer = get_node("CanvasLayer/Layer2")
@onready var top_overlay = get_node("CanvasLayer/Layer2/TopTexture")
@onready var east_overlay = get_node("CanvasLayer/Layer2/TopTexture/EastTexture")
@onready var west_overlay = get_node("CanvasLayer/Layer2/TopTexture/WestTexture")
@onready var north_overlay = get_node("CanvasLayer/Layer2/TopTexture/NorthTexture")
@onready var south_overlay = get_node("CanvasLayer/Layer2/TopTexture/SouthTexture")

const side_1 = preload("res://assets/texture/overlay/1.png")
const side_2 = preload("res://assets/texture/overlay/2.png")
const side_3 = preload("res://assets/texture/overlay/3.png")
const side_4 = preload("res://assets/texture/overlay/4.png")
const side_5 = preload("res://assets/texture/overlay/5.png")
const side_6 = preload("res://assets/texture/overlay/6.png")
const side_king = preload("res://assets/texture/overlay/king.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	display_moves_left()
	display_dice()
	
func display_moves_left():
	if abs(TurnMng.from_id) != 0:
		moves_left.text = "MOVES LEFT : " + str(abs(TurnMng.from_id))
	else:
		if TurnMng.current_turn == TurnMng.Player.P_WHITE:
			moves_left.text = "WHITE´s Turn!"
		else:
			moves_left.text = "BLACK´s Turn!"
			
func display_dice():
	var key = str(TurnMng.from_x) + "|" + str(TurnMng.from_y)
	if Globals.dice_states.has(key):
		layer_dice.show()
		var faces = Globals.dice_states[key]
		top_overlay.texture = set_faces(faces.top)
		east_overlay.texture = set_faces(faces.east)
		west_overlay.texture = set_faces(faces.west)
		north_overlay.texture = set_faces(faces.north)
		south_overlay.texture = set_faces(faces.south)
	else:
		layer_dice.hide()

func set_faces(face):
	if face == 1:
		return side_1
	elif face == 2:
		return side_2
	elif face == 3:
		return side_3
	elif face == 4:
		return side_4
	elif face == 5:
		return side_5
	elif face == 6:
		return side_6
	else:
		return side_king
