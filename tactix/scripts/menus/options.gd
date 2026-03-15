extends Control

@onready var canvas_layer: CanvasLayer = get_node("../Control/CanvasLayer")
@onready var layer: CanvasLayer = get_node("CanvasLayer")
@onready var main: Button = $CanvasLayer/MAIN

func _ready() -> void:
	layer.hide()
	canvas_layer.show()

	Windowmng.window_changed.connect(_on_window_changed)
	_update_visibility()

	if Globals.DEBUG == true:
		AudioServer.set_bus_volume_db(2, -40)

func _process(delta: float) -> void:
	if TurnMng.game_over == false:
		if Windowmng.previous == Windowmng.Screen.MAIN_MENU:
			main.hide()
		else:
			main.show()
	else:
		main.hide()

func _on_window_changed(_from, _to):
	_update_visibility()

func _update_visibility():
	if Windowmng.is_open(Windowmng.Screen.OPTIONS):
		layer.show()
	else:
		layer.hide()

func _on_exit_pressed() -> void:
	Windowmng.close()

	if Windowmng.is_open(Windowmng.Screen.MAIN_MENU):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, value)

func _on_fov_slider_value_changed(value: int) -> void:
	Globals.FOV = value

func _on_sens_slider_value_changed(value: int) -> void:
	Globals.SENS = value

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_main_pressed() -> void:
	Windowmng.open(Windowmng.Screen.MAIN_MENU)
	Globals.board_clear()
	TurnMng.reset_turn_vars()
	Globals.tisch_open = false
	TurnMng.game_over = false
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
