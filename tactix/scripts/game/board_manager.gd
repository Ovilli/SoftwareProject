extends Node3D

# Variabels

var times: int = 0

#Path


# num with an + are white / num with an - are black 

func load_board():
	print("Cleard the Board")
	Globals.board.clear()
	Globals.board.append([5,0,0,0,0,0,0,0,-5])
	Globals.board.append([1,0,0,0,0,0,0,0,-1])
	Globals.board.append([2,0,0,0,0,0,0,0,-2])
	Globals.board.append([6,0,0,0,0,0,0,0,-6])
	Globals.board.append([10,0,0,0,0,0,0,0,-10])
	Globals.board.append([6,0,0,0,0,0,0,0,-6])
	Globals.board.append([2,0,0,0,0,0,0,0,-2])
	Globals.board.append([1,0,0,0,0,0,0,0,-1])
	Globals.board.append([5,0,0,0,0,0,0,0,-5])

	
	Globals.display_board()

func _ready():
	times = 0
	load_board()
	if !multiplayer.is_server():
		return
