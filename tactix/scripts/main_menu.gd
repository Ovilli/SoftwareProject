extends Control

func _ready() -> void:
	Globals.options_open = false
	Globals.main_menu = true

func _on_quit_pressed() -> void:
	get_tree().quit()



func _on_options_pressed() -> void:
	print("Not Ready Yet")
	Globals.options_open = true
	


func _on_play_pressed() -> void:
	print("Start Game")
	Globals.main_menu = false
	get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")
