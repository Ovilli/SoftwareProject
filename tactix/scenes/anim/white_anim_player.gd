extends Node

var _0_0: Marker3D:
	get:
		return get_tree().root.get_node("Main-Game/Board/0|0")
		
var CELL_WIDTH = Globals.CELL_WIDTH

const DICE = preload("uid://c7afdlm1rpk1o")
const DICE_BLACK = preload("uid://ca35rikf3jygt")

var anim_scene = preload("res://scenes/anim/white_rotation.tscn")

func _ready():
	TurnMng.piece_moved.connect(_on_piece_moved)

func _on_piece_moved(from_x, from_y, delta_x, delta_y):
	TurnMng.is_animating = true
	var times: int
	if delta_x != 0:
		times = abs(delta_x)
	elif delta_y != 0:
		times = abs(delta_y)
	var anim_instance = anim_scene.instantiate()
	get_tree().root.add_child(anim_instance)
	var anim_mesh: MeshInstance3D
	var piece = get_piece_at(from_x, from_y)
	var piece_mesh: MeshInstance3D
	var piece_instance: Node3D
	
	
	if TurnMng.current_turn == TurnMng.Player.P_WHITE:
		piece_instance = DICE.instantiate() as Node3D
	if TurnMng.current_turn == TurnMng.Player.P_BLACK:
		piece_instance = DICE_BLACK.instantiate() as Node3D
	
	anim_instance.get_node("Node3D2").hide()
	
	piece_mesh = piece_instance.get_node_or_null("Pivot/MeshInstance3D")
	anim_mesh = anim_instance.get_node_or_null("Pivot/Rot/MeshInstance3D")
	
	#TODO: adding of the correct mesh rotation
	var times_moved := 0
	var anim_player = anim_instance.get_node("AnimationPlayer")
	var rot_mesh = anim_instance.get_node("Pivot/Rot")
	var face_rot: Vector3
	var _temp_faces
	
	var key = str(from_x) + "|" + str(from_y)
	if Globals.dice_states.has(key):
		print(Globals.dice_states[key])
		face_rot = Globals.find_rotation_of_piece(key)
		rot_mesh.rotation = face_rot
		_temp_faces = Globals.dice_states[key].duplicate()
		
	if Globals.dice_states[key] == { "top": 10, "bottom": 10, "north": 10, "south": 10, "east": 10, "west": 10 }:
		piece_mesh = piece.get_node("Pivot/MeshInstance3D")
	
	while times_moved != times:
		
		if piece and anim_mesh:
			if piece_mesh:
				anim_mesh.mesh = piece_mesh.mesh
		var x = from_x
		var y = from_y
		if delta_x > 0:
			anim_instance.rotation_degrees.y = 0
			rot_mesh.rotation_degrees.y += 0
			_temp_faces = TurnMng.roll_right(_temp_faces)
			x+=times_moved
		elif delta_x < 0:
			anim_instance.rotation_degrees.y = 180
			rot_mesh.rotation_degrees.y -= 180
			_temp_faces = TurnMng.roll_left(_temp_faces)
			x-=times_moved
		elif delta_y > 0:
			anim_instance.rotation_degrees.y = -90 
			rot_mesh.rotation_degrees.y += 90
			_temp_faces = TurnMng.roll_forward(_temp_faces)
			y += times_moved
		elif delta_y < 0:
			anim_instance.rotation_degrees.y = 90
			rot_mesh.rotation_degrees.y -= 90
			_temp_faces = TurnMng.roll_backward(_temp_faces)
			y-=times_moved
		
# TODO: adding the faces &&renewing the pivot of animation
		anim_instance.global_position = _0_0.global_position + Vector3(
		x * CELL_WIDTH + CELL_WIDTH * 0.5,
		-CELL_WIDTH / 2,
		y * CELL_WIDTH + CELL_WIDTH * 0.5
		)
		
		anim_player.play("white_rotation")
		await anim_player.animation_finished
		rot_mesh.rotation = find_anim_rotation(_temp_faces)
		times_moved += 1

	anim_instance.queue_free()
	TurnMng.is_animating = false
	Globals.display_board()
	times_moved = 0
	
	
func get_piece_at(x, y) -> Node3D:
	for piece in get_tree().get_nodes_in_group("visual_pieces"):
		if piece.get_meta("board_x") == x and piece.get_meta("board_y") == y:
			return piece
	return null
	
func find_anim_rotation(faces):
	var top = faces.top
	var north = faces.north
	var rot_values = Globals.find_top_of_piece(top, north)
	return Vector3(deg_to_rad(rot_values[0]), deg_to_rad(rot_values[1]), deg_to_rad(rot_values[2]))
