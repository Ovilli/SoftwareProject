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
	var anim_instance = anim_scene.instantiate()
	get_tree().root.add_child(anim_instance)
	if TurnMng.current_turn == TurnMng.Player.P_WHITE:
		anim_instance.get_node("Node3D").hide()
	else:
		anim_instance.get_node("Node3D2").hide()
	anim_instance.global_position = _0_0.global_position + Vector3(
		from_x * CELL_WIDTH + CELL_WIDTH * 0.5,
		-CELL_WIDTH / 2,
		from_y * CELL_WIDTH + CELL_WIDTH * 0.5
	)
	if TurnMng.current_turn == TurnMng.Player.P_BLACK:
		delta_x = -delta_y
		delta_y = -delta_x
	if delta_x > 0:
		anim_instance.rotation_degrees.y = 90
	elif delta_x < 0:
		anim_instance.rotation_degrees.y = 180
	elif delta_y > 0:
		anim_instance.rotation_degrees.y = -90
	elif delta_y < 0:
		anim_instance.rotation_degrees.y = 0
	var anim_player = anim_instance.get_node("AnimationPlayer")
	
	if TurnMng.current_turn == TurnMng.Player.P_WHITE:
		anim_player.play("black_rotation")	
	if TurnMng.current_turn == TurnMng.Player.P_BLACK:
		anim_player.play("white_rotation")
	
	await anim_player.animation_finished
	Globals.display_board()
	anim_instance.queue_free()
	TurnMng.is_animating = false
	
