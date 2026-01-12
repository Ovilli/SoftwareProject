extends Camera3D

@export var sensitivity: float = 0.003
var yaw: float = 0.0
var pitch: float = 0.0

func _ready():
	# Lock mouse for FPS-style rotation
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity
		pitch = clamp(pitch, -1.5, 1.5)
		rotation = Vector3(pitch, yaw, 0)

# this is ai ai ai ai ai ai 
