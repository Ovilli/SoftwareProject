extends Control
@onready var canvas_layer: CanvasLayer = $CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	canvas_layer.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if TurnMng.game_over:
		canvas_layer.show()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
#TODO: fix the bug of resetting whole game
#TODO: playtime, winner display
#TODO: board speichern
#TODO: multiple board & play states -> speichern/laden
#TODO: multiplayer
#TODO: KI Gegner
#TODO: game revievs
#TODO: niom niom niom
#TODO: yay
#TODO: hehehehaaa
