extends Camera3D

@export var sensitivity: float = 0.003
@onready var PERFECT_OUTLINE_SHADER = preload("uid://5xmiss1l4sy7")
@onready var top_camera: Camera3D = $"../../Camera-Top"
@onready var player_camera: Camera3D = self
const OPEN = preload("uid://u3nth41qu6lu")
@onready var sfx: AudioStreamPlayer = $"../../SFX"
@onready var options: Control = $"../../Options"
const SELECT = preload("uid://d4nncgwclo7yu")
const WRONG_SELECT = preload("uid://bc5unvw46qnoy")


var yaw: float = 0.0
var pitch: float = 0.0

func _ready():
	# mouse locken
	switch_to_player_camera()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	options.hide()
	print(options, options.visible)
	

func _input(event):
	if event is InputEvent and Input.is_action_just_pressed("esc") and Globals.options_open == false:
		if Globals.options_open == false and player_camera.current == true:
			options.show()
			Globals.options_open = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			
		if player_camera.current == false:
			sfx.stream = OPEN
			sfx.play()
		switch_to_player_camera()
		
			
			
			
		
	# Mouse motion: shoot ray for hover
	if event is InputEventMouseMotion:
		shoot_ray()
	# Left mouse button pressed: shoot ray for click
	elif event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.pressed:
		shoot_ray(true)  # Pass click flag
		
	
		

# this is ai ai ai ai ai ai 
# this not
# https://www.youtube.com/watch?v=mJRDyXsxT9g
# shader #https://godotshaders.com/shader/clean-pixel-perfect-outline-via-material-3/
func shoot_ray(is_click=false):
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000.0
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length

	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to

	var raycast_result = space.intersect_ray(ray_query)
	if raycast_result.is_empty():
		return

	var hit_object = raycast_result.collider
	if hit_object == null:
		return
		
	
	check_for_piece_data(hit_object, is_click)

func check_for_piece_data(node: Node, is_click=false):
	var current = node
	while current != null:
		# Check current node first before moving up
		if current.has_node("PieceData"):
			var piece_data = current.get_node("PieceData")
			var piece_id = int(piece_data.get_meta("piece_id"))
			var index = int(piece_data.get_meta("index"))
			
			if is_click:
				if TurnMng.current_turn == TurnMng.player.p_white:
					if piece_id < 0:
						print("not your piece")
						sfx.stream = WRONG_SELECT
						sfx.play()
					else:
						TurnMng.select_piece(piece_id, index)
						sfx.stream = SELECT
						sfx.play()
				elif TurnMng.current_turn == TurnMng.player.p_black:	
					if piece_id > 0:
						print("not your piece")
						sfx.stream = WRONG_SELECT
						sfx.play()
					else:
						TurnMng.select_piece(piece_id, index)
						sfx.stream = SELECT
						sfx.play()
			return
		
		# Special check for board/table click
		if current.name == "Tabel" and current is Node3D:
			if is_click and player_camera.current == true and Globals.options_open == false:
				sfx.stream = OPEN
				sfx.play()
				switch_to_top_camera()
			return
		
		# Move up the hierarchy
		current = current.get_parent()


func switch_to_top_camera():
	player_camera.current = false
	top_camera.current = true
	
	
func switch_to_player_camera():
	player_camera.current = true
	top_camera.current = false
