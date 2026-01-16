extends Node3D


const BOARD_SIZE =  9 # 9 x 9 Board 
const CELL_WIDTH = 1.10000002384186 # mesh size damit all genau auf ihr feld passen

var times: int = 0

const DICE_BLACK = preload("uid://ca35rikf3jygt")

const DICE_BLACK_KING = preload("uid://cetr5sbfhrby0")
const DICE = preload("uid://c7afdlm1rpk1o")
const DICE_KING = preload("uid://cgbm78yds67ov")


@onready var _0_0: Marker3D = $"0|0" # Marker der 0 0 markiert und woran sich alle figuren orientieren


var players_turn := true  # if true it is  whites trun , if false it is  blacks turn 
var board : Array = [] # an list of all positions of the board aswell as what pice is on it 
var players_state := true # if true player is selecting , if false player confirmed turn

# num with an + are white / num with an - are black 

func load_board():
	print("Cleard the Board")
	board.clear()
	board.append([5,0,0,0,0,0,0,0,-5])
	board.append([1,0,0,0,0,0,0,0,-1])
	board.append([2,0,0,0,0,0,0,0,-2])
	board.append([6,0,0,0,0,0,0,0,-6])
	board.append([10,0,0,0,0,0,0,0,-10])
	board.append([6,0,0,0,0,0,0,0,-6])
	board.append([2,0,0,0,0,0,0,0,-2])
	board.append([1,0,0,0,0,0,0,0,-1])
	board.append([5,0,0,0,0,0,0,0,-5])
	
	display_board()

func _ready():
	load_board()
	

func display_board():
	print("Displaying Board")
	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			var piece_id = board[x][y]
			if piece_id == 0:  # 0 = nichts 
				continue
				
			var scene : PackedScene
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
				# https://docs.godotengine.org/en/stable/tutorials/3d/using_transforms.html
				if piece_id == 1 or piece_id == -1: # ist das pice eine 1 ?
					# -90 0 0
					return Vector3(deg_to_rad(-90), 0, 0) # ist das pice eine 2 ?
				elif piece_id == 2 or piece_id == -2:
					# 0 0 0
					return Vector3(0, 0, 0)
				elif piece_id == 3 or piece_id == -3:# ist das pice eine 3 ?
					# 0 0 90
					return Vector3(0, 0, deg_to_rad(90)) # ist das pice eine 4 ?
				elif piece_id == 4 or piece_id == -4:
					# 0 0 -90
					return Vector3(0, 0, deg_to_rad(-90)) # ist das pice eine 5 ?
				elif piece_id == 5 or piece_id == -5:
					# 0 0 180
					return Vector3(0, 0, deg_to_rad(180)) # ist das pice eine 6 ?
				elif piece_id == 6 or piece_id == -6:
					# 90 0 0
					return Vector3(deg_to_rad(90), 0, 0) # ist das pice eine 6 ?
				return Vector3.ZERO
								
func spawn_piece(scene: PackedScene, x, y, piece_id):
	var piece_instance = scene.instantiate() as Node3D
	add_child(piece_instance) # add to tree first

	# Now you can safely use global_position
	piece_instance.global_position = _0_0.global_position + Vector3(
		x * CELL_WIDTH + CELL_WIDTH * 0.5,
		- CELL_WIDTH/2,
		y * CELL_WIDTH + CELL_WIDTH * 0.5
	)
	times += 1

	

	# Rotate around pivot
	var pivot = piece_instance.get_node("Pivot") as Node3D
	pivot.rotation = find_rotation_of_piece(piece_id)
	
	#Custom Pice ID
	var custom_piece_node := Node.new()
	custom_piece_node.name = "PieceData"
	custom_piece_node.set_meta("piece_id", piece_id)
	custom_piece_node.set_meta("index", times)

	piece_instance.add_child(custom_piece_node)
