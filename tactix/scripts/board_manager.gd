extends Node3D


const BOARD_SIZE =  9
const CELL_WIDTH = 1.10000002384186

const BOX = preload("uid://kin1civoox8r")
const DICE = preload("uid://cejfohddoqyog")
const DICE_BLACK = preload("uid://qybkw75qflsr")
@onready var _0_0: Marker3D = $"0|0"


# Need some type of State ( Players Turn , Player Selecting Pice , Players_turn) 

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
			if piece_id == 0:
				continue

			var mesh : Mesh
			if piece_id > 0:
				mesh = DICE
			else:
				mesh = DICE_BLACK

			spawn_piece(mesh, x, y)
			print("Spawning piece at:", x, y)


func spawn_piece(mesh:Mesh, x:int, y:int):
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	add_child(instance)

	instance.global_position = _0_0.global_position + Vector3(
	x * CELL_WIDTH + CELL_WIDTH * 0.5,
	0.0,
	y * CELL_WIDTH + CELL_WIDTH * 0.5
)
	
	
	
