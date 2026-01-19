extends CharacterBody3D

#Variabels
const BASE_SPEED := 17.0
const SPRINT_MULTIPLIER := 3
const JUMP_VELOCITY = 7.0
var speed := BASE_SPEED
var look_dir: Vector2
var camera_sens = Globals.SENS

#Paths
const walking = preload("uid://bdpbbr32ie2mo")
@onready var sfx: AudioStreamPlayer = $Sfx
@onready var speedlines: CanvasLayer = $"../Control/Speedlines"
@onready var camera = $Camera3D
@onready var id: Label3D = $Id

func _ready() -> void:
	if not multiplayer.is_server():
		register_player_name(Globals.player_name)
	_update_name_label()
	# Only enable camera for the player we control
	if camera:
		if is_multiplayer_authority():
			camera.current = true
		else:
			camera.current = false

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Update camera FOV and sensitivity
	if camera and camera.fov != Globals.FOV:
		camera.fov = Globals.FOV
		
	if camera_sens != Globals.SENS:
		camera_sens = Globals.SENS
	
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Get the input direction and handle the movement/deceleration
	var input_dir := Input.get_vector("right", "left", "down", "up")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Globals.options_open == false and Globals.tisch_open == false:
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			
		if direction and is_on_floor():
			if not sfx.playing:
				sfx.stream = walking
				sfx.play()
		else:
			if sfx.playing:
				sfx.stop()
			
		_rotate_camera(delta)
		move_and_slide()

func _rotate_camera(delta: float, sens_mod: float = 1.0):
	if not camera:
		return
		
	var input = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	look_dir += input
	rotation.y -= look_dir.x * camera_sens * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO

func _input(event: InputEvent):
	# Only process input for our own character
	if not is_multiplayer_authority():
		return
		
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.01


@rpc("any_peer", "reliable")
func register_player_name(name_from_peer: String):
	var sender_id = multiplayer.get_remote_sender_id()
	NetworkHandler.player_names[sender_id] = name_from_peer

	if is_multiplayer_authority():
		Globals.player_name = name_from_peer
		_update_name_label()

	print("Registered player name:", name_from_peer, "from peer", sender_id)


	
func _update_name_label() -> void:
	var peer_id := get_multiplayer_authority()

	if Globals.player_name == "":
		id.text = "Player %d" % peer_id
	else:
		id.text = "%s (ID: %d)" % [Globals.player_name, peer_id]
