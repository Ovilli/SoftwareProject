extends Control

@onready var texture_rect: TextureRect = get_node("/root/Main-Game/Control/CanvasLayer/TextureRect")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure the TextureRect starts hidden if options are open
	if Globals.options_open:
		texture_rect.hide()
	else:
		texture_rect.show()


func _process(delta: float) -> void:
	# Show or hide the texture_rect based on global options state
	if Globals.options_open:
		texture_rect.hide()
	else:
		texture_rect.show()


func _on_exit_pressed() -> void:
	hide()
	Globals.options_open = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
