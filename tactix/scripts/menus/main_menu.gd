extends Control

func _ready() -> void:
	Windowmng.open(Windowmng.Screen.MAIN_MENU)
	Windowmng.window_changed.connect(_on_window_changed)
	_update_visibility()

func _on_window_changed(_from, _to) -> void:
	_update_visibility()

func _update_visibility() -> void:
	if Windowmng.is_open(Windowmng.Screen.MAIN_MENU):
		show()
	else:
		hide()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_options_pressed() -> void:
	Debug.log("Opening Options")
	Windowmng.open(Windowmng.Screen.OPTIONS)

func _on_play_pressed() -> void:
	Debug.log("Start Game")
	Windowmng.open(Windowmng.Screen.MULTI)

func _on_how_to_play_pressed() -> void:
	Globals.how_to_open = true
	get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")


func _on_credits_pressed() -> void:
	Windowmng.open(Windowmng.Screen.CREDITS)
