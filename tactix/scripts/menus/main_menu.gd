extends Control

func _ready() -> void:
	Globals.options_open = false
	Globals.main_menu = true
	Globals.how_to_open = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(_delta):
	
	if Globals.how_to_open == true or Globals.options_open == true:
		hide()
	else:
		show()

func _on_options_pressed() -> void:
	Debug.log("Not Ready Yet")
	Globals.options_open = true

func _on_play_pressed() -> void:
	Debug.log("Start Game")
	Globals.main_menu = false
	get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")

func _on_how_to_play_pressed() -> void:
	Globals.how_to_open = true
