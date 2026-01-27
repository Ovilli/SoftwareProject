extends Node

# Variabels
enum player {p_black, p_white}
var current_turn: player = player.p_white


var board = "board_manager"
var camera = "camera_3d"

var game_over: bool = false
var last_changed: String = ""
var x_moving_direction: String = ""
var y_moving_direction: String = ""
var movedxy: bool = false
var ymoved: bool = false
var xmoved: bool = false
var moved_sth: bool
var is_piece_zero: bool = false
var can_move: bool 
var pos_moves:Array = []
var no_pos_moves:Array = []
var from_x: int
var from_y: int
var from_id: int
var original_x: int
var original_y: int
var original_id:int
	
func _ready() -> void:
	start_turn()


func switch_turn():
	if game_over:
		return
	reset_turn_vars()
	if current_turn ==player.p_white:
		print("b")
		current_turn =player.p_black
	else:
		current_turn = player.p_white
		print("w")
	
func start_turn():
	match current_turn:
		player.p_white:
			print("w")

		player.p_black:
			print("b")
func reset_turn_vars():
	x_moving_direction = ""
	y_moving_direction = ""
	movedxy = false
	ymoved = false
	xmoved = false
	moved_sth = false
	last_changed = ""
	is_piece_zero = false
	Globals.waiting_for_first = true
	from_x = -1
	from_y = -1	

func reset_turn():
	if ((current_turn == player.p_black and original_id <=0) or (current_turn == player.p_white and original_id >= 0)) and moved_sth:
		print("reset last turn")
		var piece = Globals.board[from_x][from_y]
		Globals.board[from_x][from_y] = 0 
		Globals.board[original_x][original_y] = piece
		Globals.display_board()
		reset_turn_vars()
func legal_move(first_x, first_y, first_id, second_x, second_y):
	var to_x = second_x
	var to_y = second_y
	if not moved_sth:
		from_x = first_x
		from_y = first_y
		from_id = first_id
		original_x = first_x
		original_y = first_y
		original_id = first_id
		if abs(first_id) == 10:
			from_id = 1
	#print("px: ",from_x," py: ", from_y," pid: ", from_id," bx: ", to_x," by: ", to_y)
	
	if xmoved and ymoved:
		movedxy = true
	if from_x == to_x:
		if movedxy and last_changed=="x":
			return
		else:
			if abs(from_y - to_y) <= abs(from_id):
				var expected_id = (abs(from_id) - abs(from_y-to_y))
				move_possible(from_x, first_y, to_x, to_y, expected_id)
				if can_move:
					var temp_id: int
					temp_id = (abs(from_id) - abs(from_y-to_y))
					if current_turn == player.p_black:
						temp_id = - temp_id
					y_place_piece(from_x, from_y, to_x, to_y)
					#Globals.board[to_x][to_y] = calc_id
					#change turns if piece moved everything---------------------
					if temp_id == 0:
						switch_turn()
					#New setup--------------------------------------------------
					from_id = temp_id
					from_x = to_x
					from_y = to_y
					to_x = -1
					to_y = -1
					return
					#-----------------------------------------------------------
				else:
					return
			else:
				print("no")
				return
	elif from_y == to_y:
		if movedxy and last_changed=="y":
			return
		else:
			if abs(from_x - to_x) <= abs(from_id):
				var expected_id = (abs(from_id) - abs(from_x-to_x))
				move_possible(from_x, from_y, to_x, to_y, expected_id)
				if can_move:
					var temp_id: int
					temp_id = (abs(from_id) - abs(from_x-to_x))
					if current_turn == player.p_black:
						temp_id = - temp_id
					x_place_piece(from_x, from_y, to_x, to_y)
					#Globals.board[to_x][to_y] = calc_id
					#change turns if piece moved everything---------------------
					if temp_id == 0:
						switch_turn()
					#New setup--------------------------------------------------
					from_id = temp_id
					from_x = to_x
					from_y = to_y
					to_x = -1
					to_y = -1
					return
					#-----------------------------------------------------------
				else:
					return
			else:
				print("no")
				return
	elif to_x == -1:
		print("...choice pending...")
	else:
		print("you can´t move there")
		
func move_possible(mp_from_x, mp_from_y, mp_to_x, mp_to_y, expected_id):
	can_move = true
	var tile_x = mp_from_x
	var tile_y = mp_from_y
	#ensuring, that movingdirection doesn´t change------------------------------
	if x_moving_direction == "+" and mp_from_x > mp_to_x:
		can_move = false
	if x_moving_direction == "-" and mp_from_x < mp_to_x:
		can_move = false
	if y_moving_direction == "+" and mp_from_y > mp_to_y:
		can_move = false
	if y_moving_direction == "-" and mp_from_y < mp_to_y:
		can_move = false
	if can_move == false:
		return
	#---------------------------------------------------------------------------
	#Checking if any piese is blocking the choosen path-------------------------
	if mp_from_x == mp_to_x:
		var dir = 1
		if mp_from_y > mp_to_y:
			dir = -1
			
		for tiles in range(abs(mp_from_y - mp_to_y)):
			if tiles == (abs(mp_from_y - mp_to_y) -1):
				is_piece_zero = true
			tile_y = tile_y + dir
			check_for_piece(tile_x, tile_y, expected_id)
	else:
		var dir = 1
		if mp_from_x > mp_to_x:
			dir = -1
		for tiles in range(abs(mp_from_x - mp_to_x)):
			if tiles == (abs(mp_from_x - mp_to_x) -1):
				is_piece_zero = true
			tile_x = tile_x + dir
			check_for_piece(tile_x, tile_y, expected_id)
			
func check_for_piece(tile_x, tile_y, expected_id):
	var checked_tile = Globals.board[tile_x][tile_y]

	if checked_tile != 0:
		if is_piece_zero and expected_id == 0:
			if current_turn == player.p_black and checked_tile > 0:
				capture_piece(tile_x, tile_y)
				can_move = true
			elif current_turn == player.p_white and checked_tile < 0:
				capture_piece(tile_x, tile_y)
				can_move = true
			else:
				can_move = false
		else:
			can_move = false
			return
	else:
		can_move = true
#-------------------------------------------------------------------------------
func x_place_piece(x_from_x, x_from_y, x_to_x, x_to_y):
	var piece = Globals.board[x_from_x][x_from_y]
	Globals.board[x_from_x][x_from_y] = 0 
	Globals.board[x_to_x][x_to_y] = piece 
	Globals.display_board()
	
	
	
	#setting flags----------------------
	xmoved = true
	last_changed = "x"
	Globals.waiting_for_first = false
	moved_sth = true
	if x_from_x < x_to_x:
		x_moving_direction = "+"
	elif x_from_x > x_to_x:
		x_moving_direction = "-"
	#-----------------------------------

func y_place_piece(y_from_x, y_from_y, y_to_x, y_to_y):
	var piece = Globals.board[y_from_x][y_from_y]
	Globals.board[y_from_x][y_from_y] = 0 
	Globals.board[y_to_x][y_to_y] = piece
	
	Globals.display_board()
	
	
	#setting flags----------------------
	ymoved = true
	last_changed = "y"
	Globals.waiting_for_first = false
	moved_sth = true
	if y_from_y < y_to_y:
		y_moving_direction = "+"
	elif y_from_y > y_to_y:
		y_moving_direction = "-"
	#-----------------------------------

func capture_piece(tile_x, tile_y):
	print("capture piece")
	var piece = Globals.board[tile_x][tile_y]
	if abs(piece) == 10:
		if piece == 10:
			print("b wins")
		elif piece == -10:
			print("w wins")
		game_over = true 
		
	Globals.board[tile_x][tile_y] = 0


func light_pieces_up(piece_id, tile_x, tile_y):
	Debug.log("light up")
	pos_moves.clear()
	no_pos_moves.clear()
	var num = 0
	if abs(piece_id) == 10:
		num = 1
		check_light_up(num, tile_x, tile_y, piece_id)
	else:
		num = piece_id
		check_light_up(num, tile_x, tile_y, piece_id)

func check_possible_move(check_x, check_y, is_final_position):
	var checked_tile = Globals.board[check_x][check_y]
	
	if checked_tile == 0:
		pos_moves.append([check_x, check_y])
		return true
	elif is_final_position:
		if (current_turn == player.p_black and checked_tile > 0) or \
		   (current_turn == player.p_white and checked_tile < 0):
			pos_moves.append([check_x, check_y])
		else:
			no_pos_moves.append([check_x, check_y])
		return false
	else:
		no_pos_moves.append([check_x, check_y])
		return false

func check_light_up(num, tile_x, tile_y, piece_id):
	for i in range(1, num + 1):
		var new_x = tile_x + i
		if new_x >= 0 and new_x < Globals.BOARD_SIZE:
			if not check_possible_move(new_x, tile_y, i == piece_id):
				break
		else:
			break

	for i in range(1, num + 1):
		var new_x = tile_x - i
		if new_x >= 0 and new_x < Globals.BOARD_SIZE:
			if not check_possible_move(new_x, tile_y, i == piece_id):
				break
		else:
			break

	for i in range(1, num + 1):
		var new_y = tile_y + i
		if new_y >= 0 and new_y < Globals.BOARD_SIZE:
			if not check_possible_move(tile_x, new_y, i == piece_id):
				break
		else:
			break

	for i in range(1, num + 1):
		var new_y = tile_y - i
		if new_y >= 0 and new_y < Globals.BOARD_SIZE:
			if not check_possible_move(tile_x, new_y, i == piece_id):
				break
		else:
			break
#lighting up possable tiles would be nice
#adding code so the new piece_id is the side facing top
#set boolean if King is captured -> winning screen
#helpful overlays (moves left over, ...)
#fixing rotation of top_camera
#softlock protection
