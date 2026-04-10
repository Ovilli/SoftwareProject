extends Control

@onready var quit_layer: CanvasLayer = $QuitLayer
@onready var saveloadask: Control = $QuitLayer/SAVELOADASK

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quit_layer.hide()
	saveloadask.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Windowmng.is_open(Windowmng.Screen.QUIT):
		quit_layer.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		quit_layer.hide()


func _on_ja_pressed() -> void:
	quit_layer.hide()
	saveloadask.show()


func _on_nein_pressed() -> void:
	Windowmng.open(Windowmng.previous)


func _on_nah_pressed() -> void:
	get_tree().quit()


func _on_save_pressed() -> void:
	SaveLoadGame.save_game()
	get_tree().quit()
