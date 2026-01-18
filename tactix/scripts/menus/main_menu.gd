extends Control

func _ready() -> void:
	Globals.options_open = false
	Globals.main_menu = true
	Globals.how_to_open = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(_delta):
	
	
	if Globals.how_to_open == true or Globals.options_open == true or Globals.muliplayer_open == true:
		hide()
	else:
		show()

func _on_options_pressed() -> void:
	print("Not Ready Yet")
	Globals.options_open = true

func _on_play_pressed() -> void:
	print("Start Game")
	Globals.main_menu = false
	Globals.muliplayer_open = true

func _on_how_to_play_pressed() -> void:
	Globals.how_to_open = true
