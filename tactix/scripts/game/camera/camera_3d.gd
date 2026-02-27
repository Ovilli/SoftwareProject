extends Camera3D

# Variables (fixed typo)
@export var sensitivity: float = 0.003
@onready var player_camera: Camera3D = self

# Sounds
const OPEN = preload("uid://u3nth41qu6lu")
const SELECT = preload("uid://d4nncgwclo7yu")
const WRONG_SELECT = preload("uid://bc5unvw46qnoy")

# Paths
@onready var top_camera = get_node("/root/Main-Game/Camera-Top")
@onready var top_camera_2 = get_node("/root/Main-Game//Camera-Top2")
@onready var options = get_node("/root/Main-Game/Options")
@onready var PERFECT_OUTLINE_SHADER = preload("uid://5xmiss1l4sy7")
@onready var sfx = get_node("../Sfx")
@onready var texture_rect: TextureRect = get_node("/root/Main-Game/Control/CanvasLayer/TextureRect")
@onready var top_camera_enabled: bool = false

var first_x: int = -1
var first_y: int = -1
var first_id: int = 0
var second_x: int = -1
var second_y: int = -1
var second_id: int = 0

var yaw: float = 0.0
var pitch: float = 0.0

var is_transitioning: bool = false


func _ready():
	switch_to_player_camera()
	options.hide()


func _input(event):
	if event is InputEvent and Input.is_action_just_pressed("esc") and Globals.options_open == false and Globals.option_alr_open == false:
		if Globals.options_open == false and player_camera.current == true and Globals.option_alr_open == false:
			options.show()
			Globals.options_open = true
			Globals.option_alr_open = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
		if player_camera.current == false:
			sfx.stream = OPEN
			sfx.play()
			Globals.tisch_open = false
			texture_rect.visible = true
			switch_to_player_camera()
			
	# Mouse motion: shoot ray for hover
	if event is InputEventMouseMotion:
		shoot_ray()
	# Left mouse button pressed: shoot ray for click
	elif event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.pressed:
		shoot_ray(true)  # Pass click flag
		
	if event is InputEvent and Input.is_action_just_pressed("r") and Globals.options_open == false:
		TurnMng.reset_turn()
		Globals.clear_move_markers()
		play_sound_sfx()


# https://www.youtube.com/watch?v=mJRDyXsxT9g
# shader #https://godotshaders.com/shader/clean-pixel-perfect-outline-via-material-3/
func shoot_ray(is_click: bool = false):
	var cam = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000.0
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * ray_length

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


func check_for_piece_data(node: Node, is_click: bool = false):
	var current_node = node
	while current_node != null:
		# Check current node first before moving up
		if current_node.has_node("PieceData"):
			var piece_data = current_node.get_node("PieceData")
			var piece_id = int(piece_data.get_meta("piece_id"))
			var x = int(piece_data.get_meta("x"))
			var y = int(piece_data.get_meta("y"))
			
			# IMPORTANT: If a move is in progress, read the CURRENT value from the board
			# not the original value from metadata
			if TurnMng.moved_sth:
				piece_id = Globals.board[x][y]
			
			if is_click:
				if Globals.waiting_for_first:
					first_x = x
					first_y = y
					first_id = piece_id  # Now uses the correct current value
					second_x = -1
					second_y = -1

					# VALIDATE PIECE OWNERSHIP FIRST
					if first_id != 0:
						var is_valid_piece = false
						# Check if piece belongs to current player
						if TurnMng.current_turn == TurnMng.Player.P_WHITE and first_id > 0:
							is_valid_piece = true
						elif TurnMng.current_turn == TurnMng.Player.P_BLACK and first_id < 0:
							is_valid_piece = true
						
						if is_valid_piece:
							# Valid piece - accept selection
							Globals.waiting_for_first = false
							Globals.clear_move_markers()
							marker_click()
							play_sound_sfx()
						else:
							# Invalid piece - reject and show message
							Debug.log("not your piece")
							play_sound_sfx()
							Globals.clear_move_markers()
							# waiting_for_first stays true
				else:
					if not (first_x == x and first_y == y):
						second_x = x
						second_y = y
						second_id = piece_id  # Uses current value
						var different_color: bool = false
						
						# FIXED: Use TurnMng.Player instead of TurnMng.player
						if (TurnMng.current_turn == TurnMng.Player.P_WHITE and second_id < 0) or (TurnMng.current_turn == TurnMng.Player.P_BLACK and second_id > 0):
							different_color = true
						
						if second_id != 0 and different_color == false:
							first_x = second_x
							first_y = second_y
							first_id = second_id
							second_x = -1
							second_y = -1
							Globals.clear_move_markers()
							marker_click()
						else:
							Globals.waiting_for_first = false
							play_sound_sfx()
							TurnMng.legal_move(first_x, first_y, first_id, second_x, second_y)
							if second_x != -1 and second_y != -1:
								Globals.clear_move_markers()
							else:
								first_id = Globals.board[first_x][first_y]
								marker_click()
					else:
						Debug.log("Cannot select same position")
						return  # Exit early to prevent calling legal_move
			return
		
		# Special check for board/table click
		if current_node.name == "Tabel" and current_node is Node3D:
			if is_click and top_camera_enabled == false and Globals.options_open == false:
				play_sound_sfx()
				switch_to_top_camera()
				Globals.tisch_open = true
			return
		
		current_node = current_node.get_parent()


func play_sound_sfx():
	sfx.stream = SELECT
	sfx.play()


func switch_to_top_camera():
	player_camera.current = false
	top_camera_enabled = true
	texture_rect.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	var target: Camera3D
	if TurnMng.current_turn == TurnMng.Player.P_WHITE:
		target = top_camera_2
		top_camera.current = false
	else:
		target = top_camera
		top_camera_2.current = false
	
	var destination = target.global_transform
	target.global_transform = player_camera.global_transform
	target.current = true
	is_transitioning = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "global_transform", destination, 0.6)
	tween.tween_callback(func(): is_transitioning = false)


func marker_click():
	Globals.clear_move_markers()
	TurnMng.light_pieces_up(abs(first_id), first_x, first_y)
	Globals.highlight_possible_moves()


func _process(_delta: float) -> void:
	rotate_camera_nice()


func rotate_camera_nice():
	if top_camera_enabled and not is_transitioning:
		if TurnMng.current_turn == TurnMng.Player.P_WHITE:
			if not top_camera_2.current:
				is_transitioning = true
				var destination = top_camera_2.global_transform
				top_camera_2.global_transform = top_camera.global_transform
				top_camera_2.current = true
				top_camera.current = false
				var tween = create_tween()
				tween.set_ease(Tween.EASE_IN_OUT)
				tween.set_trans(Tween.TRANS_CUBIC)
				tween.tween_property(top_camera_2, "global_transform", destination, 0.6)
				tween.tween_callback(func(): is_transitioning = false)
		else:
			if not top_camera.current:
				is_transitioning = true
				var destination = top_camera.global_transform
				top_camera.global_transform = top_camera_2.global_transform
				top_camera.current = true
				top_camera_2.current = false
				var tween = create_tween()
				tween.set_ease(Tween.EASE_IN_OUT)
				tween.set_trans(Tween.TRANS_CUBIC)
				tween.tween_property(top_camera, "global_transform", destination, 0.6)
				tween.tween_callback(func(): is_transitioning = false)


func switch_to_player_camera():
	top_camera_enabled = false
	top_camera.current = false
	top_camera_2.current = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var prev_transform = get_viewport().get_camera_3d().global_transform
	player_camera.current = true
	var destination = player_camera.global_transform
	player_camera.global_transform = prev_transform
	is_transitioning = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(player_camera, "global_transform", destination, 0.6)
	tween.tween_callback(func(): is_transitioning = false)
	#TODO: fix the cracked states of the player_camera
