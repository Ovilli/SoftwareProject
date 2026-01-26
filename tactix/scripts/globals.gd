extends Node

#Variabels
var options_open:bool = false
var FOV :int = 90
var SENS :int= 20
var main_menu :bool = false
var how_to_open :bool = false
var tisch_open :bool = false
var waiting_for_first: bool = true
var DEBUG : bool = true
var GAME_OVER : bool = false
var board : Array = []


const BOARD_SIZE =  9
const CELL_WIDTH = 1.10000002384186
var times: int = 0

#Paths
const DICE_BLACK = preload("uid://ca35rikf3jygt")
const HIDDEN = preload("uid://dtr152fgi0j5n")
const DICE_BLACK_KING = preload("uid://cetr5sbfhrby0")
const DICE = preload("uid://c7afdlm1rpk1o")
const DICE_KING = preload("uid://cgbm78yds67ov")
const MARKER = preload("uid://uloumind7w3b")
const GREEN = preload("uid://b4npdqee326a2")
const RED = preload("uid://c24i4tcdvluvv")

var _0_0: Marker3D:
	get:
		return get_tree().root.get_node("Main-Game/Board/0|0")

func display_board():
	print("Displaying Board")
	
	board_clear()
	
	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			var piece_id = board[x][y]
			
				
			var scene : PackedScene
			if piece_id == 0:  # 0 = nichts 
				scene = HIDDEN
				
			if piece_id > 0 and piece_id < 7: # gucken ob es weiß ist 
				scene = DICE # setzen variable mesh auf DICE => eine weiße figur  wird gepsawnt
			else:
				if piece_id == 10: # gucken ob es ein könig ist 
					scene = DICE_KING # setzen variable mesh auf KING => ein könig wird gepsawnt
				else:
					if piece_id < 0 and piece_id > -7: # gucken ob es schwarz ist
						scene = DICE_BLACK # setzen variable mesh auf DICE_BLACK => eine schwarze figur wird gepsawnt
					else:
						# gucken ob es ein schwarzer könig ist 
						if piece_id == -10:
							scene = DICE_BLACK_KING # setzen variable mesh auf KING_BLACK => ein schwarzer  könig wird gepsawnt
						
			spawn_piece(scene, x, y, piece_id)
			# print("Spawning piece at:", x, y, mesh)
			
func find_rotation_of_piece(piece_id):
	# Verwende den absoluten Wert, um die Rotation zu bestimmen
	var display_value = abs(piece_id)
	
	# Für Könige (10) zeige die "1" Seite
	if display_value == 10:
		display_value = 1
	
	# Rotationen für jede Würfelseite
	if display_value == 1:
		# -90 0 0
		return Vector3(deg_to_rad(-90), 0, 0)
	elif display_value == 2:
		# 0 0 0
		return Vector3(0, 0, 0)
	elif display_value == 3:
		# 0 0 90
		return Vector3(0, 0, deg_to_rad(90))
	elif display_value == 4:
		# 0 0 -90
		return Vector3(0, 0, deg_to_rad(-90))
	elif display_value == 5:
		# 0 0 180
		return Vector3(0, 0, deg_to_rad(180))
	elif display_value == 6:
		# 90 0 0
		return Vector3(deg_to_rad(90), 0, 0)
	
	return Vector3.ZERO

func spawn_piece(scene: PackedScene, x, y, piece_id):
	var piece_instance = scene.instantiate() as Node3D
	
	piece_instance.add_to_group("visual_pieces")
	
	add_child(piece_instance)

	# setze die globale position
	piece_instance.global_position = _0_0.global_position + Vector3(
		x * CELL_WIDTH + CELL_WIDTH * 0.5,
		- CELL_WIDTH/2,
		y * CELL_WIDTH + CELL_WIDTH * 0.5
	)
	times += 1

	

	# rotitire am pivot
	var pivot = piece_instance.get_node("Pivot") as Node3D
	pivot.rotation = find_rotation_of_piece(piece_id)
	
	#Custom Pice ID ebscpeicher in der meta 
	var piece_data := Node.new()
	piece_data.name = "PieceData"
	piece_data.set_meta("piece_id", piece_id)
	piece_data.set_meta("index", times)
	piece_data.set_meta("x", x)
	piece_data.set_meta("y", y)
	piece_instance.add_child(piece_data)

func board_clear():

	var old_pieces = get_tree().get_nodes_in_group("visual_pieces")
	for piece in old_pieces:
		piece.queue_free() # This safely deletes the object

func highlight_possible_moves():
	clear_move_markers()

	# Grün für mögliche Züge
	for move in TurnMng.pos_moves:
		spawn_marker(move[0], move[1], GREEN)

	# Rot für unmögliche Züge
	for move in TurnMng.no_pos_moves:
		spawn_marker(move[0], move[1], RED)


func spawn_marker(x, y, material: Material):
	# Instanziiere den Marker als Szene
	var marker_instance = MARKER.instantiate() as Node3D
	add_child(marker_instance)
	marker_instance.add_to_group("move_markers")

	# Position auf dem Board
	marker_instance.global_position = _0_0.global_position + Vector3(
		x * CELL_WIDTH + CELL_WIDTH * 0.5,
		0.05,
		y * CELL_WIDTH + CELL_WIDTH * 0.5
	)

	# Material anwenden
	var mesh_instance = marker_instance.get_node_or_null("MeshInstance3D")
	if mesh_instance and mesh_instance is MeshInstance3D:
		mesh_instance.set_surface_override_material(0, material)


func clear_move_markers():
	var markers_to_clear = get_tree().get_nodes_in_group("move_markers")
	for marker in markers_to_clear:
		marker.queue_free()
		
