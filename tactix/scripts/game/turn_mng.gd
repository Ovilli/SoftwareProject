extends Node

# Variabels
enum player {p_black, p_white}
var current_turn : player =player.p_white
var game_over : bool=false

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
func move_piece(piece_id, index):
	print(piece_id, "|", index)
	#var move_dir := Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
	#print(move_dir)
	#var movement = 
