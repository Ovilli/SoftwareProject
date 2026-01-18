extends Camera3D

const MOUSE_SCALE := 0.002
const RETURN_FORCE := 5.0
const DAMPING := 6.0
const MAX_YAW := 0.4   # radians (~23°)

var yaw := 0.0
var yaw_velocity := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	rotation.y = 0.0

func _process(delta: float) -> void:
	# Integrate velocity
	yaw += yaw_velocity * delta

	# Spring back to center
	yaw_velocity += (-yaw * RETURN_FORCE) * delta

	# Damping
	yaw_velocity -= yaw_velocity * DAMPING * delta

	# Clamp angle
	yaw = clamp(yaw, -MAX_YAW, MAX_YAW)

	rotation.y = yaw

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw_velocity -= event.relative.x * MOUSE_SCALE
