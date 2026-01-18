extends Control


@onready var canvas_layer: CanvasLayer = $"../Control/CanvasLayer"


func _ready() -> void:
	_sync_canvas_visibility()

func _process(_delta: float) -> void:
	_sync_canvas_visibility()

func _sync_canvas_visibility() -> void:
	if Globals.options_open == true:
		canvas_layer.hide()
		show()
		
	else:
		hide()
		canvas_layer.show()

func _on_exit_pressed() -> void:
	hide()
	Globals.options_open = false
	if Globals.main_menu == true and Globals.options_open == false:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, value)

func _on_fov_slider_value_changed(value: int) -> void:
	Globals.FOV = value

func _on_sens_slider_value_changed(value: int) -> void:
	Globals.SENS = value

func _on_quit_pressed() -> void:
	get_tree().quit()
