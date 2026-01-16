extends Node

enum player {p_black, p_white}
var current_turn : player =player.p_white
var game_over : bool=false
# Called when the node enters the scene tree for the first time.
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
			#controlls
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(current_turn)
