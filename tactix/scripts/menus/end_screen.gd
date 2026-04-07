extends Control
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var winner: Label = get_node("CanvasLayer/winner")
@onready var item_list: ItemList = get_node("CanvasLayer/ItemList")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	canvas_layer.hide()




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	
	if TurnMng.game_over and !TurnMng.is_animating:
		canvas_layer.show()
		Globals.clear_move_markers()
		var formatted_time = format_time()
		item_list.set_item_text(1, str(Globals.counter))
		item_list.set_item_text(3, formatted_time)
		if TurnMng.black_wins:
			winner.text = "BLACK WON!"
		else:
			winner.text = "WHITE WON!"
	else:
		canvas_layer.hide()
func format_time():
	var time = int(Globals.time)
	@warning_ignore("integer_division")
	var hours = time / 3600
	@warning_ignore("integer_division")
	var minutes = (time % 3600) / 60
	var seconds = time % 60
	var time_string = "%02d:%02d:%02d" % [hours, minutes, seconds]
	return time_string
	
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	Globals.board_clear()
	TurnMng.reset_turn_vars()
	Globals.tisch_open = false
	TurnMng.game_over = false
	TurnMng.current_turn = TurnMng.Player.P_WHITE
	Globals.multiplayer_enabeld = false
	Globals.GAME_ID = " "
	Globals.player_id = "        "
	Globals.first_state_received = false
	Globals.last_server_version = -1
	Debug.log("Reset", Debug.TYPES.SUCCSESS)
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")


#TODO: KI Gegner
#TODO: game revievs
#TODO: niom niom niom
