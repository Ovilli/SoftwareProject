extends Node

# Variabels
enum player {p_black, p_white}
var current_turn : player =player.p_white
var game_over : bool=false
var input_on_board: Callable

var camera = "camera_3d"


func _ready() -> void:
	start_turn()

func switch_turn():
	if game_over:
		return
	if current_turn ==player.p_white:
		current_turn =player.p_black
	else:
		current_turn = player.p_white
func start_turn():
	match current_turn:
		player.p_white:
			print("w")
			#controlls
		player.p_black:
			print("b")
func move_piece(piece_id, x, y):
	print("piece_id: ",piece_id, " | ","x: " , x, " | ", "y: ", y)

	input_on_board=func(event):
		if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.pressed:
			camera.shoot_ray()
			print("piece_id: ",piece_id, " | ","x: " , x, " | ", "y: ", y)
			legal_move(piece_id, x, y)
		elif event is InputEventKey and Input.is_action_just_pressed("esc"):
			return
		
func legal_move(piece_id, x, y):
	#add moving rules
	pass
