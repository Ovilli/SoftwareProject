extends Camera3D

@export var sensitivity: float = 0.003
@onready var player_camera: Camera3D = self

const OPEN = preload("uid://u3nth41qu6lu")
const SELECT = preload("uid://d4nncgwclo7yu")
const WRONG_SELECT = preload("uid://bc5unvw46qnoy")

@onready var top_camera = get_node("/root/Main-Game/Camera-Top")
@onready var top_camera_2 = get_node("/root/Main-Game/Camera-Top2")
@onready var top_camera_3 = get_node("/root/Main-Game/Camera-Top3")
@onready var top_camera_4 = get_node("/root/Main-Game/Camera-Top4")
@onready var sfx = get_node("../Sfx")
@onready var texture_rect: TextureRect = get_node("/root/Main-Game/Control/CanvasLayer/TextureRect")
@onready var top_camera_enabled: bool = false
@onready var layer: CanvasLayer = get_node("/root/Main-Game/Control/CanvasLayer")

var first_x: int = -1
var first_y: int = -1
var first_id: int = 0
var second_x: int = -1
var second_y: int = -1
var second_id: int = 0

var yaw: float = 0.0
var pitch: float = 0.0
var is_transitioning: bool = false

var cam_home: Transform3D
var cam2_home: Transform3D
var cam3_home: Transform3D
var cam4_home: Transform3D

func _ready() -> void:
	cam_home = top_camera.global_transform
	cam2_home = top_camera_2.global_transform
	cam3_home = top_camera_3.global_transform
	cam4_home = top_camera_4.global_transform
	switch_to_player_camera()

func _input(event: InputEvent) -> void:
	if is_transitioning:
		return
	if Input.is_action_just_pressed("esc"):
		if Windowmng.is_open(Windowmng.Screen.OPTIONS):
			Windowmng.close()
			layer.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			if player_camera.current:
				Windowmng.open(Windowmng.Screen.OPTIONS)
				layer.hide()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				sfx.stream = OPEN
				sfx.play()
				Globals.tisch_open = false
				texture_rect.visible = true
				switch_to_player_camera()
	if TurnMng.is_animating:
		return
	if event is InputEventMouseMotion:
		shoot_ray()
	elif event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event.pressed:
		shoot_ray(true)

	if Input.is_action_just_pressed("r") and not Windowmng.is_open(Windowmng.Screen.OPTIONS):
		TurnMng.reset_turn()
		Globals.clear_move_markers()
		if first_x != -1 and first_y != -1:
			first_id = Globals.board[first_x][first_y]
		play_sound_sfx()

func shoot_ray(is_click: bool = false) -> void:
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

func check_for_piece_data(node: Node, is_click: bool = false) -> void:
	var current_node = node
	while current_node != null:
		if current_node.has_node("PieceData"):
			var piece_data = current_node.get_node("PieceData")
			var piece_id = int(piece_data.get_meta("piece_id"))
			var x = int(piece_data.get_meta("x"))
			var y = int(piece_data.get_meta("y"))

			if TurnMng.moved_sth:
				piece_id = Globals.board[x][y]

			if is_click:
				if Globals.waiting_for_first:
					first_x = x
					first_y = y
					first_id = piece_id
					second_x = -1
					second_y = -1
					if first_id != 0:
						var is_valid_piece = false
						if TurnMng.current_turn == TurnMng.Player.P_WHITE and first_id > 0:
							is_valid_piece = true
						elif TurnMng.current_turn == TurnMng.Player.P_BLACK and first_id < 0:
							is_valid_piece = true
						if is_valid_piece:
							Globals.waiting_for_first = false
							Globals.clear_move_markers()
							if !TurnMng.moved_sth:
								marker_click()
								play_sound_sfx()
						else:
							Debug.log("not your piece")
							play_sound_sfx()
				else:
					if not (first_x == x and first_y == y):
						second_x = x
						second_y = y
						second_id = piece_id
						var different_color: bool = false
						if (TurnMng.current_turn == TurnMng.Player.P_WHITE and second_id < 0) or (TurnMng.current_turn == TurnMng.Player.P_BLACK and second_id > 0):
							different_color = true
						if second_id != 0 and different_color == false:
							first_x = second_x
							first_y = second_y
							first_id = second_id
							second_x = -1
							second_y = -1
							Globals.waiting_for_first = false
							if !TurnMng.moved_sth:
								marker_click()
						else:
							TurnMng.legal_move(first_x, first_y, first_id, second_x, second_y)
							if TurnMng.moved_sth:
								play_sound_sfx()
								if not Globals.waiting_for_first:
									first_x = TurnMng.from_x
									first_y = TurnMng.from_y
									first_id = Globals.board[first_x][first_y]
									Globals.clear_move_markers()
									marker_click()
								else:
									Globals.clear_move_markers()
							else:
								first_id = Globals.board[first_x][first_y]
								Globals.waiting_for_first = false
								Globals.clear_move_markers()
								marker_click()
					else:
						Debug.log("Cannot select same position")
						return
			return

		if current_node.name == "Tabel" and current_node is Node3D:
			if is_click and top_camera_enabled == false and not Windowmng.is_open(Windowmng.Screen.OPTIONS):
				play_sound_sfx()
				switch_to_top_camera()
				Globals.tisch_open = true
			return

		current_node = current_node.get_parent()

func play_sound_sfx() -> void:
	sfx.stream = SELECT
	sfx.play()

func switch_to_top_camera() -> void:
	player_camera.current = false
	top_camera_enabled = true
	texture_rect.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	var target: Camera3D
	if TurnMng.current_turn == TurnMng.Player.P_WHITE:
		if Globals.SPECHT_MODE == false:
			target = top_camera_2
			top_camera.current = false
		else:
			target = top_camera_4
			top_camera_3.current = false
	else:
		if Globals.SPECHT_MODE == false:
			target = top_camera
			top_camera_2.current = false
		else:
			target = top_camera_3
			top_camera_4.current = false
	var destination = target.global_transform
	target.global_transform = player_camera.global_transform
	target.current = true
	is_transitioning = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "global_transform", destination, 0.6)
	tween.tween_callback(func(): is_transitioning = false)

func marker_click() -> void:
	Globals.clear_move_markers()
	TurnMng.overlay_x = first_x
	TurnMng.overlay_y = first_y
	TurnMng.light_pieces_up(abs(first_id), first_x, first_y)
	Globals.highlight_possible_moves()

func _process(_delta: float) -> void:
	rotate_camera_nice()

func rotate_camera_nice() -> void:
	if Globals.SPECHT_MODE == false:
		if top_camera_enabled and not is_transitioning:
			if TurnMng.current_turn == TurnMng.Player.P_WHITE:
				if not top_camera_2.current:
					is_transitioning = true
					top_camera_2.global_transform = top_camera.global_transform
					top_camera_2.current = true
					top_camera.current = false
					var tween = create_tween()
					tween.set_ease(Tween.EASE_IN_OUT)
					tween.set_trans(Tween.TRANS_CUBIC)
					tween.tween_property(top_camera_2, "global_transform", cam2_home, 0.6)
					tween.tween_callback(func(): is_transitioning = false)
			else:
				if not top_camera.current and Globals.how_to_open == false:
					is_transitioning = true
					top_camera.global_transform = top_camera_2.global_transform
					top_camera.current = true
					top_camera_2.current = false
					var tween = create_tween()
					tween.set_ease(Tween.EASE_IN_OUT)
					tween.set_trans(Tween.TRANS_CUBIC)
					tween.tween_property(top_camera, "global_transform", cam_home, 0.6)
					tween.tween_callback(func(): is_transitioning = false)
	else:
		if top_camera_enabled and not is_transitioning:
			if TurnMng.current_turn == TurnMng.Player.P_WHITE:
				if not top_camera_4.current:
					is_transitioning = true
					top_camera_4.global_transform = top_camera_3.global_transform
					top_camera_4.current = true
					top_camera_3.current = false
					var tween = create_tween()
					tween.set_ease(Tween.EASE_IN_OUT)
					tween.set_trans(Tween.TRANS_CUBIC)
					tween.tween_property(top_camera_4, "global_transform", cam4_home, 0.6)
					tween.tween_callback(func(): is_transitioning = false)
			else:
				if not top_camera_3.current and Globals.how_to_open == false:
					is_transitioning = true
					top_camera_3.global_transform = top_camera_4.global_transform
					top_camera_3.current = true
					top_camera_4.current = false
					var tween = create_tween()
					tween.set_ease(Tween.EASE_IN_OUT)
					tween.set_trans(Tween.TRANS_CUBIC)
					tween.tween_property(top_camera_3, "global_transform", cam3_home, 0.6)
					tween.tween_callback(func(): is_transitioning = false)

func switch_to_player_camera() -> void:
	# Disable top cameras
	top_camera_enabled = false
	if Globals.SPECHT_MODE == false:
		top_camera.current = false
		top_camera_2.current = false
	else:
		top_camera_3.current = false
		top_camera_4.current = false

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var player = get_parent()
	if not player:
		player_camera.current = true
		return

	var forward = -player.global_transform.basis.z
	var up = Vector3.UP
	var right = forward.cross(up).normalized()
	up = right.cross(forward).normalized()
	var target_global_basis = Basis(right, up, -forward)

	var target_local_rotation = target_global_basis.get_euler()

	var start_rotation = rotation

	yaw = rad_to_deg(target_local_rotation.y)
	pitch = rad_to_deg(target_local_rotation.x)

	player_camera.current = true
	is_transitioning = true

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "rotation", target_local_rotation, 0.6)
	tween.tween_callback(func():
		is_transitioning = false
		var rot = rotation
		yaw = rad_to_deg(rot.y)
		pitch = rad_to_deg(rot.x)
	)
