extends Node

var _0_0: Marker3D:
	get:
		return get_tree().root.get_node("Main-Game/Board/0|0")
var CELL_WIDTH = Globals.CELL_WIDTH



var anim_scene = preload("res://scenes/anim/white_rotation.tscn")


# Called when the node enters the scene tree for the first time.
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
	var anim_mesh
	var piece = get_piece_at(from_x, from_y)
	anim_instance.get_node("Node3D2").hide()
	anim_mesh = anim_instance.get_node_or_null("Node3D/MeshInstance3D")
	#TODO: adding of the correct mesh rotation
	var times_moved := 0
	var anim_player = anim_instance.get_node("AnimationPlayer")
	
	
	while times_moved != times:
		
		var x = from_x
		var y = from_y
		
		if delta_x > 0:
			anim_instance.rotation_degrees.y = 0
			x+=times_moved
		elif delta_x < 0:
			anim_instance.rotation_degrees.y = 180
			x-=times_moved
		elif delta_y > 0:
			anim_instance.rotation_degrees.y = -90
			y += times_moved
		elif delta_y < 0:
			anim_instance.rotation_degrees.y = 90
			y-=times_moved
			
		if piece and anim_mesh:
			var piece_mesh = piece.get_node_or_null("Pivot/MeshInstance3D")
			var piece_pivot = piece.get_node_or_null("Pivot")
			if piece_mesh:
				anim_mesh.mesh = piece_mesh.mesh
			if piece_pivot:
				print("piece_pivot rotation: ", piece_pivot.rotation)
				anim_instance.get_node("Node3D").rotation = piece_pivot.rotation
				print("Node3D rotation after set: ", anim_instance.get_node("Node3D").rotation)
		anim_instance.global_position = _0_0.global_position + Vector3(
		x * CELL_WIDTH + CELL_WIDTH * 0.5,
		-CELL_WIDTH / 2,
		y * CELL_WIDTH + CELL_WIDTH * 0.5
		)
		
		anim_player.play("white_rotation")
		await anim_player.animation_finished
		times_moved += 1
	
	anim_instance.queue_free()
	Globals.display_board()
	times_moved = 0
	TurnMng.is_animating = false
	
func get_piece_at(x, y) -> Node3D:
	for piece in get_tree().get_nodes_in_group("visual_pieces"):
		if piece.get_meta("board_x") == x and piece.get_meta("board_y") == y:
			return piece
	return null
