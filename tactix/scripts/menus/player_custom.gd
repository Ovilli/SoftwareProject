extends Control

@onready var player_custom_layer: CanvasLayer = $player_custom_layer

func _process(_delta):
	if Globals.how_to_open == true or Globals.options_open == true or Globals.muliplayer_open == true or Globals.main_menu == true:
		hide()
		player_custom_layer.hide()
	else:
		show()
		player_custom_layer.show()

func _on_name_text_changed(new_text: String) -> void:
	Globals.player_name = new_text



func _on_button_pressed() -> void:
	Globals.player_custom_open = false
	Globals.muliplayer_open =true
