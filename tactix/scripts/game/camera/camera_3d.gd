extends Camera3D

#Variabels
@export var sensitivity: float = 0.003
@onready var player_camera: Camera3D = self

#Sounds
const OPEN = preload("uid://u3nth41qu6lu")
const SELECT = preload("uid://d4nncgwclo7yu")
const WRONG_SELECT = preload("uid://bc5unvw46qnoy")


#Paths
@onready var top_camera = get_node("/root/Main-Game/Camera-Top")
@onready var options = get_node("/root/Main-Game/Options")
@onready var PERFECT_OUTLINE_SHADER = preload("uid://5xmiss1l4sy7")
@onready var sfx = get_node("../Sfx")
@onready var texture_rect: TextureRect = get_node("/root/Main-Game/Control/CanvasLayer/TextureRect")

var first_x: int
var first_y: int
var first_id:int
var second_x: int
var second_y: int
var second_id: int

var yaw: float = 0.0
var pitch: float = 0.0


func _ready():
	switch_to_player_camera()
	options.hide()

func _input(event):
	if event is InputEvent and Input.is_action_just_pressed("esc") and Globals.options_open == false:
		if Globals.options_open == false and player_camera.current == true:
			options.show()
			Globals.options_open = true
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
		play_sound_sfx()
		Globals.clear_move_markers()
		marker_click()
		
# https://www.youtube.com/watch?v=mJRDyXsxT9g
# shader #https://godotshaders.com/shader/clean-pixel-perfect-outline-via-material-3/
func shoot_ray(is_click=false):
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

func check_for_piece_data(node: Node, is_click=false):
	var current_node = node
	while current_node != null:
		# Check current node first before moving up
		if current_node.has_node("PieceData"):
			var piece_data = current_node.get_node("PieceData")
			var piece_id = int(piece_data.get_meta("piece_id"))
			var x = int(piece_data.get_meta("x"))
			var y = int(piece_data.get_meta("y"))
			
			if is_click:
				if Globals.waiting_for_first:
					first_x = x
					first_y = y
					first_id = piece_id
					second_x = -1 #killing the variable
					second_y = -1

					if first_id != 0:
						Globals.waiting_for_first = false
						Globals.clear_move_markers()
						marker_click()
				else:
					if not (first_x == x and first_y == y):
						second_x = x
						second_y = y
						second_id = piece_id
						var diffrent_color: bool = false
						if (TurnMng.current_turn == TurnMng.player.p_white and second_id < 0) or (TurnMng.current_turn == TurnMng.player.p_black and second_id > 0):
							diffrent_color = true
						
						if second_id != 0 and diffrent_color == false:
							first_x = second_x
							first_y = second_y
							first_id = second_id
							second_x = -1 #killing the variable
							second_y = -1
						else:
							Globals.waiting_for_first = false
					else:
						print("no same pos")
						Globals.clear_move_markers()
						marker_click()
						
				if TurnMng.current_turn == TurnMng.player.p_white:  
					if first_id <= -1:
						print("ynot your piece")
						play_sound_sfx()
						Globals.clear_move_markers()
						marker_click()
					else:
						switch_to_top_camera()
						play_sound_sfx()
						TurnMng.legal_move(first_x, first_y, first_id, second_x, second_y)
						marker_click()
						
				elif TurnMng.current_turn == TurnMng.player.p_black:
					if first_id >= 1:
						print("xnot your piece")
						play_sound_sfx()
						Globals.clear_move_markers()
					
					else:
						switch_to_top_camera()
						
						Globals.clear_move_markers()
						TurnMng.legal_move(first_x, first_y, first_id, second_x, second_y)
						marker_click()
			
		
		# Special check for board/table click
		if current_node.name == "Tabel" and current_node is Node3D:
			if is_click and player_camera.current == true and Globals.options_open == false:
				play_sound_sfx()
				switch_to_top_camera()
				Globals.tisch_open = true
			return
		
		current_node = current_node.get_parent()
		
		
func play_sound_sfx():
	sfx.stream = SELECT
	sfx.play()
	
	
func switch_to_top_camera():
	"""if TurnMng.current_turn == TurnMng.player.p_white:
		top_camera.rotate_y(deg_to_rad(180.0))"""
	player_camera.current = false
	top_camera.current = true
	texture_rect.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func marker_click():
	Globals.clear_move_markers()
	TurnMng.light_pieces_up(abs(first_id), first_x, first_y)
	Globals.highlight_possible_moves()


func switch_to_player_camera():
	
	player_camera.current = true
	top_camera.current = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	"""top_camera.rotation = Vector3.ZERO
	top_camera.rotate_x(deg_to_rad(-90.0))"""
