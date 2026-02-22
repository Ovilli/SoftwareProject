extends Node

# Variables (fixed typo from "Variabels")
enum Player {P_BLACK, P_WHITE}
var current_turn: Player = Player.P_WHITE

# Make the enum accessible from other scripts
var player = Player

var board = "board_manager"
var camera = "camera_3d"

var game_over: bool = false
var last_changed: String = ""
var x_moving_direction: String = ""
var y_moving_direction: String = ""
var movedxy: bool = false
var ymoved: bool = false
var xmoved: bool = false
var moved_sth: bool = false
var is_piece_zero: bool = false
var can_move: bool = false
var pos_moves: Array = []
var no_pos_moves: Array = []
var from_x: int = -1
var from_y: int = -1
var from_id: int = 0
var original_x: int = 0
var original_y: int = 0
var original_id: int = 0
var is_king_piece: bool = false


func _ready() -> void:
	start_turn()


func switch_turn():
	if game_over:
		return
	reset_turn_vars()
	if current_turn == Player.P_WHITE:
		print("b")
		current_turn = Player.P_BLACK
	else:
		current_turn = Player.P_WHITE
		print("w")
	start_turn()

	
func start_turn():
	match current_turn:
		Player.P_WHITE:
			print("w")
		Player.P_BLACK:
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
	is_king_piece = false
	Globals.waiting_for_first = true
	from_x = -1
	from_y = -1


func reset_turn():
	if ((current_turn == Player.P_BLACK and original_id <= 0) or (current_turn == Player.P_WHITE and original_id >= 0)) and moved_sth:
		print("reset last turn")
		var piece = Globals.board[from_x][from_y]
		Globals.board[from_x][from_y] = 0 
		Globals.board[original_x][original_y] = piece
		Globals.display_board()
		reset_turn_vars()


func legal_move(first_x, first_y, first_id, second_x, second_y):
	if second_x == -1 or second_y == -1:
		return
	
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
			is_king_piece = true
			from_id = 1
		else:
			is_king_piece = false
	
	if xmoved and ymoved:
		movedxy = true
	
	if from_x == to_x:
		if movedxy and last_changed == "x":
			print("Cannot move in Y direction again after moving in both directions")
			return
		else:
			if abs(from_y - to_y) <= abs(from_id):
				var expected_id = (abs(from_id) - abs(from_y - to_y))
				move_possible(from_x, first_y, to_x, to_y, expected_id)
				if can_move:
					var temp_id: int = (abs(from_id) - abs(from_y - to_y))
					if current_turn == Player.P_BLACK:
						temp_id = -temp_id
					
					var prev_x = from_x
					var prev_y = from_y
					
					y_place_piece(from_x, from_y, to_x, to_y)
					
					update_piece_id_with_positions(prev_x, prev_y, to_x, to_y)
					
					if temp_id == 0:
						switch_turn()
						return
					
					from_id = temp_id
					from_x = to_x
					from_y = to_y
					return
				else:
					print("Move blocked")
					return
			else:
				print("Distance too far for current piece value")
				return
	
	elif from_y == to_y:
		if movedxy and last_changed == "y":
			print("Cannot move in X direction again after moving in both directions")
			return
		else:
			if abs(from_x - to_x) <= abs(from_id):
				var expected_id = (abs(from_id) - abs(from_x - to_x))
				move_possible(from_x, from_y, to_x, to_y, expected_id)
				if can_move:
					var temp_id: int = (abs(from_id) - abs(from_x - to_x))
					if current_turn == Player.P_BLACK:
						temp_id = -temp_id
					
					var prev_x = from_x
					var prev_y = from_y
					
					x_place_piece(from_x, from_y, to_x, to_y)
					
					update_piece_id_with_positions(prev_x, prev_y, to_x, to_y)
					
					if temp_id == 0:
						switch_turn()
						return
					
					from_id = temp_id
					from_x = to_x
					from_y = to_y
					return
				else:
					print("Move blocked")
					return
			else:
				print("Distance too far for current piece value")
				return
	
	else:
		print("You can't move diagonally")


func move_possible(mp_from_x, mp_from_y, mp_to_x, mp_to_y, expected_id):
	can_move = true
	var tile_x = mp_from_x
	var tile_y = mp_from_y
	
	if x_moving_direction == "+" and mp_from_x > mp_to_x:
		can_move = false
		print("Cannot reverse X direction")
	if x_moving_direction == "-" and mp_from_x < mp_to_x:
		can_move = false
		print("Cannot reverse X direction")
	if y_moving_direction == "+" and mp_from_y > mp_to_y:
		can_move = false
		print("Cannot reverse Y direction")
	if y_moving_direction == "-" and mp_from_y < mp_to_y:
		can_move = false
		print("Cannot reverse Y direction")
	
	if not can_move:
		return
	
	if mp_from_x == mp_to_x:
		var dir = 1 if mp_from_y < mp_to_y else -1
		
		for tiles in range(abs(mp_from_y - mp_to_y)):
			if tiles == (abs(mp_from_y - mp_to_y) - 1):
				is_piece_zero = true
			tile_y = tile_y + dir
			check_for_piece(tile_x, tile_y, expected_id)
			if not can_move:
				break
	else:
		var dir = 1 if mp_from_x < mp_to_x else -1
		
		for tiles in range(abs(mp_from_x - mp_to_x)):
			if tiles == (abs(mp_from_x - mp_to_x) - 1):
				is_piece_zero = true
			tile_x = tile_x + dir
			check_for_piece(tile_x, tile_y, expected_id)
			if not can_move:
				break


func check_for_piece(tile_x, tile_y, expected_id):
	var checked_tile = Globals.board[tile_x][tile_y]

	if checked_tile != 0:
		if is_piece_zero and expected_id == 0:
			if current_turn == Player.P_BLACK and checked_tile > 0:
				capture_piece(tile_x, tile_y)
				can_move = true
			elif current_turn == Player.P_WHITE and checked_tile < 0:
				capture_piece(tile_x, tile_y)
				can_move = true
			else:
				can_move = false
		else:
			can_move = false
			return
	else:
		can_move = true


func x_place_piece(x_from_x, x_from_y, x_to_x, x_to_y):
	var piece = Globals.board[x_from_x][x_from_y]
	Globals.board[x_from_x][x_from_y] = 0 
	Globals.board[x_to_x][x_to_y] = piece 
	
	xmoved = true
	last_changed = "x"
	Globals.waiting_for_first = false
	moved_sth = true
	if x_from_x < x_to_x:
		x_moving_direction = "+"
	elif x_from_x > x_to_x:
		x_moving_direction = "-"


func y_place_piece(y_from_x, y_from_y, y_to_x, y_to_y):
	var piece = Globals.board[y_from_x][y_from_y]
	Globals.board[y_from_x][y_from_y] = 0 
	Globals.board[y_to_x][y_to_y] = piece
	Globals.display_board()
	
	ymoved = true
	last_changed = "y"
	Globals.waiting_for_first = false
	moved_sth = true
	if y_from_y < y_to_y:
		y_moving_direction = "+"
	elif y_from_y > y_to_y:
		y_moving_direction = "-"


func capture_piece(tile_x, tile_y):
	print("Capturing piece at (%d, %d)" % [tile_x, tile_y])
	var piece = Globals.board[tile_x][tile_y]
	
	if abs(piece) == 10:
		if piece == 10:
			print("Black wins!")
		elif piece == -10:
			print("White wins!")
		game_over = true
	
	Globals.board[tile_x][tile_y] = 0


func light_pieces_up(piece_id, tile_x, tile_y):
	Debug.log("Highlighting possible moves")
	pos_moves.clear()
	no_pos_moves.clear()
	
	var num = 1 if abs(piece_id) == 10 else abs(piece_id)
	check_light_up(num, tile_x, tile_y, num)


func check_possible_move(check_x, check_y, is_final_position):
	var checked_tile = Globals.board[check_x][check_y]
	
	if checked_tile == 0:
		pos_moves.append([check_x, check_y])
		return true
	elif is_final_position:
		if (current_turn == Player.P_BLACK and checked_tile > 0) or (current_turn == Player.P_WHITE and checked_tile < 0):
			pos_moves.append([check_x, check_y])
		else:
			no_pos_moves.append([check_x, check_y])
		return false
	else:
		no_pos_moves.append([check_x, check_y])
		return false


func check_light_up(_num, tile_x, tile_y, remaining_moves):
	for i in range(1, remaining_moves + 1):
		var new_x = tile_x + i
		if new_x >= 0 and new_x < Globals.BOARD_SIZE:
			if not check_possible_move(new_x, tile_y, i == remaining_moves):
				break
		else:
			break

	for i in range(1, remaining_moves + 1):
		var new_x = tile_x - i
		if new_x >= 0 and new_x < Globals.BOARD_SIZE:
			if not check_possible_move(new_x, tile_y, i == remaining_moves):
				break
		else:
			break

	for i in range(1, remaining_moves + 1):
		var new_y = tile_y + i
		if new_y >= 0 and new_y < Globals.BOARD_SIZE:
			if not check_possible_move(tile_x, new_y, i == remaining_moves):
				break
		else:
			break

	for i in range(1, remaining_moves + 1):
		var new_y = tile_y - i
		if new_y >= 0 and new_y < Globals.BOARD_SIZE:
			if not check_possible_move(tile_x, new_y, i == remaining_moves):
				break
		else:
			break


func roll_forward(faces):
	var old_top = faces.top
	faces.top = faces.south
	faces.south = faces.bottom
	faces.bottom = faces.north
	faces.north = old_top


func roll_backward(faces):
	var old_top = faces.top
	faces.top = faces.north
	faces.north = faces.bottom
	faces.bottom = faces.south
	faces.south = old_top


func roll_right(faces):
	var old_top = faces.top
	faces.top = faces.west
	faces.west = faces.bottom
	faces.bottom = faces.east
	faces.east = old_top


func roll_left(faces):
	var old_top = faces.top
	faces.top = faces.east
	faces.east = faces.bottom
	faces.bottom = faces.west
	faces.west = old_top


func update_piece_id_with_positions(prev_x, prev_y, new_x, new_y):
	var key = str(prev_x) + "|" + str(prev_y)

	if not Globals.dice_states.has(key):
		return

	var faces = Globals.dice_states[key]

	var delta_x = new_x - prev_x
	var delta_y = new_y - prev_y
	
	if not is_king_piece:
		if delta_y != 0:
			if delta_y > 0:
				for i in range(abs(delta_y)):
					roll_forward(faces)
			else:
				for i in range(abs(delta_y)):
					roll_backward(faces)
		elif delta_x != 0:
			if delta_x > 0:
				for i in range(abs(delta_x)):
					roll_right(faces)
			else:
				for i in range(abs(delta_x)):
					roll_left(faces)
		
		var updated_id = faces.top
		
		if current_turn == Player.P_BLACK:
			updated_id = -updated_id
		
		Globals.board[new_x][new_y] = updated_id
		from_id = updated_id
	else:
		var king_id = 10
		if current_turn == Player.P_BLACK:
			king_id = -10
		Globals.board[new_x][new_y] = king_id
		from_id = 1
	
	Globals.move_dice_state(prev_x, prev_y, new_x, new_y)
	Globals.display_board()
