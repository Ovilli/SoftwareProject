extends Control

@export var in_time: float = 0.5
@export var fade_time: float = 1.5
@export var pause_time: float = 1.5
@export var out_time: float = 0.5



@onready var texture_rect_2: TextureRect = $CenterContainer/TextureRect2
	
@onready var texture_rect: TextureRect = $CenterContainer/TextureRect
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	if Globals.DEBUG == true:
		in_time = 0
		fade_time = 0
		pause_time = 0
		out_time = 0
		fade()
	else:
		fade()

	

func fade():
	var color = texture_rect.modulate
	color.a = 0.0
	texture_rect.modulate = color
	var tween = create_tween()
	tween.tween_interval(in_time)
	color.a = 1.0
	tween.tween_property(texture_rect, "modulate", color, fade_time)
	texture_progress_bar.set_process(100)
	tween.tween_interval(pause_time)
	color.a = 0.0
	tween.tween_property(texture_rect, "modulate", color, fade_time)
	tween.tween_interval(out_time)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
