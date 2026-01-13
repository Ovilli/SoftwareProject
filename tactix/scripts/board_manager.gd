extends Node3D


const BOARD_SIZE =  9 # 9 x 9 Board 
const CELL_WIDTH = 1.10000002384186 # mesh size damit all genau auf ihr feld passen

const BOX = preload("uid://kin1civoox8r")
const DICE = preload("uid://cejfohddoqyog")
const DICE_BLACK = preload("uid://qybkw75qflsr")
const KING = preload("uid://dyg82xwpwinl3")
const KING_BLACK = preload("uid://43g6o0d0v0yb")

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
				
			var mesh : Mesh
			if piece_id > 0 and piece_id < 7: # gucken ob es weiß ist 
				mesh = DICE # setzen variable mesh auf DICE => eine weiße figur  wird gepsawnt
			else:
				if piece_id == 10: # gucken ob es ein könig ist 
					mesh = KING # setzen variable mesh auf KING => ein könig wird gepsawnt
				else:
					if piece_id < 0 and piece_id > -7: # gucken ob es schwarz ist
						mesh = DICE_BLACK # setzen variable mesh auf DICE_BLACK => eine schwarze figur wird gepsawnt
					else:
						# gucken ob es ein schwarzer könig ist 
						if piece_id == -10:
							mesh = KING_BLACK # setzen variable mesh auf KING_BLACK => ein schwarzer  könig wird gepsawnt
						
			spawn_piece(mesh, x, y, piece_id)
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
								
func spawn_piece(mesh, x, y, piece_id):
	# Create a pivot node
	var pivot := Node3D.new()
	add_child(pivot)
	
	
	
	# Position the pivot at the center of the cell
	pivot.global_position = _0_0.global_position + Vector3(
		x * CELL_WIDTH + CELL_WIDTH * 0.5,
		0.0,
		y * CELL_WIDTH + CELL_WIDTH * 0.5
	)

	# Create the mesh instance as a child of the pivot
	var dice_mesh := MeshInstance3D.new()
	dice_mesh.mesh = mesh
	pivot.add_child(dice_mesh)
	
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(CELL_WIDTH * 0.8, CELL_WIDTH * 0.8, CELL_WIDTH * 0.8)
	collider.shape = box
	dice_mesh.add_child(collider)
	
	# Use AABB to center mesh on pivot
	var aabb = mesh.get_aabb()
	dice_mesh.position = -aabb.position - aabb.size * 0.5

	# Rotate the pivot instead of the mesh
	pivot.rotation = find_rotation_of_piece(piece_id)

	
	#TOD0
	# Fixen das die Würfel sich nicht beim rotieren bewegen : ( 
