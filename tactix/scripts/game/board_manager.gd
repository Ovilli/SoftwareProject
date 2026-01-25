extends Node3D

#Path

func load_board():
	Debug.log("Cleard the Board")
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
	Globals.times = 0
	load_board()
