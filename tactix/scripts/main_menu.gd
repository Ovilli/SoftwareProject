extends Control



func _on_quit_pressed() -> void:
	get_tree().quit()



func _on_options_pressed() -> void:
	print("Not Ready Yet")


func _on_play_pressed() -> void:
	print("Start Game")
	get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")
