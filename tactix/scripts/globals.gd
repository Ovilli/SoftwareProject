extends Node

var FOV: int = 90
var SENS: int = 20
var DEBUG: bool = true
var board: Array = []
var board_pices_updated: Array = []
var dice_states := {}
var counter: int = 0
var turns_left: int = 0
var time: float = 0.0
var waiting_for_first: bool = true
var tisch_open: bool = false
var multiplayer_enabeld: bool = false
var GAME_ID: String
var player_id: String = ""
var times: int = 0
var how_to_open: bool = false
const BOARD_SIZE = 9
const CELL_WIDTH = 1.10000002384186
var equipped_skin: int = 0
const DICE_BLACK = preload("uid://ca35rikf3jygt")
const HIDDEN = preload("uid://dtr152fgi0j5n")
const DICE_BLACK_KING = preload("uid://cetr5sbfhrby0")
const DICE = preload("uid://c7afdlm1rpk1o")
const DICE_KING = preload("uid://cgbm78yds67ov")
const GREEN = preload("uid://b4npdqee326a2")
const RED = preload("uid://c24i4tcdvluvv")
const MARKER_GREEN = preload("uid://coqj1mfu810hm")
const MARKER_RED = preload("uid://uloumind7w3b")
var SPECHT_MODE : bool = true

var _0_0: Marker3D:
	get:
		return get_tree().root.get_node("Main-Game/Board/0|0")

func _process(delta: float) -> void:
	if !TurnMng.game_over:
		time += delta

func display_board():
	board_clear()
	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			var piece_id = board[x][y]
			var scene: PackedScene
			if piece_id == 0:
				scene = HIDDEN
			elif piece_id > 0 and piece_id < 7:
				scene = DICE
			elif piece_id == 10:
				scene = DICE_KING
			elif piece_id < 0 and piece_id > -7:
				scene = DICE_BLACK
			elif piece_id == -10:
				scene = DICE_BLACK_KING
			spawn_piece(scene, x, y, piece_id)

func find_rotation_of_piece(key) -> Vector3:
	var faces = dice_states[key]
	var top = faces.top
	var north = faces.north
	var rot_values = find_top_of_piece(top, north)
	return Vector3(deg_to_rad(rot_values[0]), deg_to_rad(rot_values[1]), deg_to_rad(rot_values[2]))

func find_top_of_piece(top, north):
	var x: int = 0
	var y: int = 0
	var z: int = 0
	if top == 1:
		x = -90
		if north == 2:
			y = 180
		elif north == 3:
			y = -90
		elif north == 4:
			y = 90
		elif north == 5:
			y = 0
	elif top == 2:
		x = 0
		if north == 1:
			y = 180
		elif north == 3:
			y = -90
		elif north == 4:
			y = 90
		elif north == 6:
			y = 0
	elif top == 3:
		z = 90
		if north == 1:
			y = 0
		elif north == 2:
			y = 90
		elif north == 5:
			y = -90
		elif north == 6:
			y = 180
	elif top == 4:
		z = -90
		if north == 1:
			y = 0
		elif north == 2:
			y = -90
		elif north == 5:
			y = 90
		elif north == 6:
			y = 180
	elif top == 5:
		z = 180
		if north == 1:
			y = 0
		elif north == 3:
			y = 90
		elif north == 4:
			y = -90
		elif north == 6:
			y = 180
	elif top == 6:
		x = 90
		if north == 2:
			y = 0
		elif north == 3:
			y = -90
		elif north == 4:
			y = 90
		elif north == 5:
			y = 180
	return [x, y, z]

func spawn_piece(scene: PackedScene, x, y, piece_id) -> void:
	var piece_instance = scene.instantiate() as Node3D
	
	var skin_mesh = Diceskinmng.get_skin_mesh(piece_id)
	if skin_mesh:
		var mesh_instance = piece_instance.get_node_or_null("Pivot/MeshInstance3D")
		if mesh_instance:
			mesh_instance.mesh = skin_mesh
	
	piece_instance.add_to_group("visual_pieces")
	#New
	piece_instance.set_meta("board_x", x)
	piece_instance.set_meta("board_y", y)
	#new
	add_child(piece_instance)
	piece_instance.global_position = _0_0.global_position + Vector3(
		x * CELL_WIDTH + CELL_WIDTH * 0.5,
		-CELL_WIDTH / 2,
		y * CELL_WIDTH + CELL_WIDTH * 0.5
	)
	times += 1
	var piece_data := Node.new()
	piece_data.name = "PieceData"
	piece_data.set_meta("piece_id", piece_id)
	piece_data.set_meta("index", times)
	piece_data.set_meta("x", x)
	piece_data.set_meta("y", y)
	var key = str(x) + "|" + str(y)

	# Only initialise dice_states here in singleplayer and only if truly missing.
	# In multiplayer dice_states is owned and written exclusively by game_manager
	# so we must never overwrite it here or synced state gets corrupted.
	if piece_id != 0 and not dice_states.has(key) and not multiplayer_enabeld:
		if abs(piece_id) != 10:
			dice_states[key] = create_default_dice_faces(piece_id)
		else:
			dice_states[key] = {
				"top": 10,
				"bottom": 10,
				"north": 10,
				"south": 10,
				"east": 10,
				"west": 10
			}

	var pivot = piece_instance.get_node_or_null("Pivot")
	if pivot and dice_states.has(key):
		pivot.rotation = find_rotation_of_piece(key)
	piece_data.set_meta("dice_faces", dice_states.get(key, {}))
	piece_instance.add_child(piece_data)

func board_clear() -> void:
	var old_pieces = get_tree().get_nodes_in_group("visual_pieces")
	for piece in old_pieces:
		piece.queue_free()

func highlight_possible_moves() -> void:
	clear_move_markers()
	for move in TurnMng.pos_moves:
		spawn_marker(move[0], move[1], MARKER_GREEN)
	for move in TurnMng.no_pos_moves:
		spawn_marker(move[0], move[1], MARKER_RED)

func spawn_marker(x, y, MARKER) -> void:
	var marker_instance = MARKER.instantiate() as Node3D
	add_child(marker_instance)
	marker_instance.add_to_group("move_markers")
	marker_instance.global_position = _0_0.global_position + Vector3(
		x * CELL_WIDTH + CELL_WIDTH * 0.5,
		0.05,
		y * CELL_WIDTH + CELL_WIDTH * 0.5
	)

func clear_move_markers() -> void:
	var markers_to_clear = get_tree().get_nodes_in_group("move_markers")
	for marker in markers_to_clear:
		marker.queue_free()

func create_default_dice_faces(id: int) -> Dictionary:
	var faces = {
		"top": 2,
		"bottom": 5,
		"north": 4,
		"south": 3,
		"east": 1,
		"west": 6
	}
	var cur_id = abs(id)
	var safety_counter = 0
	while faces.top != cur_id and safety_counter < 10:
		var old_top = faces.top
		faces.top = faces.east
		faces.east = faces.bottom
		faces.bottom = faces.west
		faces.west = old_top
		safety_counter += 1
	if id > 0:
		return faces
	else:
		var old_south = faces.south
		faces.south = faces.north
		faces.north = old_south
		var old_west = faces.west
		faces.west = faces.east
		faces.east = old_west
		return faces
