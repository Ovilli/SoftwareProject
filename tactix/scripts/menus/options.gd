extends Control

#Paths
@onready var canvas_layer: CanvasLayer = get_node("../Control/CanvasLayer")
@onready var layer: CanvasLayer = get_node("CanvasLayer")


func _ready() -> void:
	layer.hide()
	canvas_layer.show()
	if Globals.DEBUG == true:
		AudioServer.set_bus_volume_db(2, -40)

func _process(_delta) -> void:
	if Globals.options_open:
		layer.show()

func _on_exit_pressed() -> void:
	layer.hide()
	Globals.options_open = false
	Globals.option_alr_open = false
	if Globals.main_menu == true and Globals.options_open == false:
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
