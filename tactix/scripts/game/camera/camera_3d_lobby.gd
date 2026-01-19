extends Camera3D

#Variabels
const MOUSE_SCALE := 0.002
const RETURN_FORCE := 5.0
const DAMPING := 6.0
const MAX_YAW := 0.4
var yaw := 0.0
var yaw_velocity := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	rotation.y = 0.0

func _process(delta: float) -> void:
	if Globals.main_menu == true:
		yaw += yaw_velocity * delta
		yaw_velocity += (-yaw * RETURN_FORCE) * delta
		yaw_velocity -= yaw_velocity * DAMPING * delta
		yaw = clamp(yaw, -MAX_YAW, MAX_YAW)
		rotation.y = yaw

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Globals.main_menu == true :
		yaw_velocity -= event.relative.x * MOUSE_SCALE
