extends CharacterBody3D

const BASE_SPEED := 17.0
const SPRINT_MULTIPLIER := 3
const  JUMP_VELOCITY = 7.0
var speed := BASE_SPEED
var look_dir: Vector2
@onready var camera=$Camera3D
var camera_sens = Globals.SENS
const walking = preload("uid://bdpbbr32ie2mo")
@onready var sfx: AudioStreamPlayer = $Sfx
@onready var speedlines: CanvasLayer = $"../Control/Speedlines"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if camera.fov != Globals.FOV:
		camera.fov = Globals.FOV
		
	if camera_sens != Globals.SENS:
		camera_sens = Globals.SENS
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_pressed("shift") and is_on_floor():
		speed = BASE_SPEED * SPRINT_MULTIPLIER
		speedlines.show()
	else:
		speed = BASE_SPEED
		speedlines.hide()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("right", "left", "down", "up")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Globals.options_open == false or Globals.tisch_open == false:
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			sfx.stream = walking
			sfx.play()
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		_rotate_camera(delta)
		move_and_slide()
	#äaisdjijaisjdasjdoasdoaisjdoiasdjoaisdj
func _rotate_camera(delta: float, sens_mod: float= 1.0):
		var input = Input.get_vector("look_left", "look_right", "look_down", "look_up")
		look_dir += input
		rotation.y -= look_dir.x * camera_sens * delta
		camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)
		look_dir = Vector2.ZERO

func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	
	
