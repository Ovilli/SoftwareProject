extends Node

enum Player {P_BLACK, P_WHITE}

signal turn_changed()
signal piece_moved(from_x: int, from_y: int, delta_x: int, delta_y: int)

var current_turn: Player = Player.P_WHITE
var my_player: Player = Player.P_WHITE
var poll_timer: Timer
var data_sender: Node = null
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
var overlay_x: int = -1
var overlay_y: int = -1
var original_x: int = 0
var original_y: int = 0
var original_id: int = 0
var is_king_piece: bool = false
var dice_states_backup := {}
var black_wins: bool = false
var is_animating: bool = false
var _move_made: bool = false


func setup_for_session() -> void:
	_init_multiplayer()
	_setup_poll_timer()
	hard_reset_manager()


func _flip_key(key: String) -> String:
	var parts := key.split("|")
	if parts.size() != 2:
		return key
	var x := int(parts[0])
	var y := int(parts[1])
	var flipped_x := Globals.BOARD_SIZE - 1 - x
	return str(flipped_x) + "|" + str(y)


func _ready() -> void:
	_init_multiplayer()
	_setup_poll_timer()


func _init_multiplayer() -> void:
	if Globals.multiplayer_enabeld:
		data_sender = Sender
		if data_sender:
			data_sender.game_manager = self
		if Globals.player_id == "player_1":
			my_player = Player.P_WHITE
		elif Globals.player_id == "player_2":
			my_player = Player.P_BLACK
		else:
			my_player = Player.P_WHITE
	else:
		my_player = Player.P_WHITE
	current_turn = Player.P_WHITE


func _setup_poll_timer() -> void:
	poll_timer = Timer.new()
	add_child(poll_timer)
	poll_timer.wait_time = 0.5
	poll_timer.timeout.connect(_poll_server)
	poll_timer.start()


func _poll_server() -> void:
	if data_sender:
		data_sender.packetGetDataList()


func _on_server_state_received(parsed: Dictionary) -> void:
	var server_version = parsed.get("version", -1)
	if server_version <= Globals.last_server_version:
		Debug.log("Ignoring stale state update (version %d <= %d)" % [server_version, Globals.last_server_version])
		return
	Globals.last_server_version = server_version

	if parsed.has("game") and parsed["game"] is Dictionary:
		parsed = parsed["game"]
	if not parsed.has("board"):
		return

	var server_board = parsed["board"]
	var server_dice_states: Dictionary = parsed.get("dice_states", {}) if parsed.has("dice_states") and parsed["dice_states"] is Dictionary else {}

	if Globals.player_id == "player_2":
		server_board = server_board.duplicate(true)
		server_board.reverse()

	var effective_dice: Dictionary = server_dice_states
	if Globals.player_id == "player_2":
		effective_dice = {}
		for old_key in server_dice_states:
			var new_key = _flip_key(old_key)
			effective_dice[new_key] = server_dice_states[old_key]

	Globals.board.clear()
	for x in range(Globals.BOARD_SIZE):
		var row: Array = []
		for y in range(Globals.BOARD_SIZE):
			row.append(0)
		Globals.board.append(row)

	for x in range(Globals.BOARD_SIZE):
		for y in range(Globals.BOARD_SIZE):
			Globals.board[x][y] = server_board[x][y]

	Globals.dice_states.clear()
	for key in effective_dice.keys():
		Globals.dice_states[key] = effective_dice[key]

	Globals.display_board()

	var turn_str = str(parsed.get("current_turn", "white")).to_lower()
	var server_turn = Player.P_BLACK if turn_str == "black" else Player.P_WHITE
	var turn_changed_on_server = (server_turn != current_turn)

	Debug.log("[TurnMng] Received server turn: %s | Local current: %s | My player: %s" % [turn_str.to_upper(), Player.keys()[current_turn], Player.keys()[my_player]])

	if not Globals.first_state_received:
		Globals.first_state_received = true
		current_turn = server_turn
		turn_changed.emit()
		if server_turn == my_player and not game_over:
			start_turn()
		return

	if turn_changed_on_server:
		Debug.log("[TurnMng] Turn changed detected. Calling start_turn() for player %s" % Player.keys()[my_player])
		current_turn = server_turn
		turn_changed.emit()
		if server_turn == my_player and not game_over:
			start_turn()


func _send_state_to_server() -> void:
	if not Globals.multiplayer_enabeld or not data_sender:
		return

	var turn_str = "black" if current_turn == Player.P_BLACK else "white"

	var board_data: Array = []
	for x in range(Globals.BOARD_SIZE):
		var row: Array = []
		for y in range(Globals.BOARD_SIZE):
			row.append(Globals.board[x][y])
		board_data.append(row)
	if Globals.player_id == "player_2":
		board_data.reverse()

	var dice_data: Dictionary = {}
	if Globals.player_id == "player_2":
		for local_key in Globals.dice_states.keys():
			var canon_key = _flip_key(local_key)
			dice_data[canon_key] = Globals.dice_states[local_key]
	else:
		for key in Globals.dice_states.keys():
			dice_data[key] = Globals.dice_states[key]

	var payload = {
		"board": board_data,
		"dice_states": dice_data,
		"current_turn": turn_str,
		"winner": "black" if black_wins else ("white" if game_over else null)
	}
	data_sender.packetSendDataList(payload)


func switch_turn() -> void:
	if game_over:
		return
	if Globals.multiplayer_enabeld and not data_sender:
		data_sender = Sender
	if data_sender:
		data_sender.game_manager = self

	reset_turn_vars()
	current_turn = Player.P_BLACK if current_turn == Player.P_WHITE else Player.P_WHITE
	turn_changed.emit()
	_send_state_to_server()

	if not Globals.multiplayer_enabeld:
		start_turn()
	elif current_turn == my_player:
		start_turn()


func start_turn() -> void:
	Debug.log("[TurnMng] start_turn() called. game_over=%s" % game_over)
	if game_over:
		return
	_move_made = false
	Globals.counter += 1
	backup_dice_states()
	Debug.log("[TurnMng] Turn started for %s" % Player.keys()[my_player])


func reset_turn_vars() -> void:
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
	from_id = 0
	overlay_x = -1
	overlay_y = -1


func reset_turn() -> void:
	if ((current_turn == Player.P_BLACK and original_id < 0) or
		(current_turn == Player.P_WHITE and original_id > 0)) and moved_sth:
		Globals.counter -= 1
	if from_x != -1 and from_y != -1:
		Globals.board[from_x][from_y] = 0
		var k = str(from_x) + "|" + str(from_y)
		if Globals.dice_states.has(k):
			Globals.dice_states.erase(k)
	Globals.board[original_x][original_y] = original_id
	restore_dice_states()
	Globals.display_board()
	reset_turn_vars()


func legal_move(first_x, first_y, first_id, second_x, second_y) -> void:
	if first_x == -1 or first_y == -1 or second_x == -1 or second_y == -1:
		return
	if current_turn == Player.P_WHITE and first_id < 0:
		return
	if current_turn == Player.P_BLACK and first_id > 0:
		return
	if Globals.multiplayer_enabeld and current_turn != my_player:
		return
	if second_x == -1 or second_y == -1:
		return

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

	if from_x == second_x:
		if (xmoved and ymoved) and last_changed == "x":
			return
		if abs(from_y - second_y) <= abs(from_id):
			var expected_id = abs(from_id) - abs(from_y - second_y)
			move_possible(from_x, first_y, second_x, second_y, expected_id)
			if can_move:
				var temp_id = abs(from_id) - abs(from_y - second_y)
				if current_turn == Player.P_BLACK:
					temp_id = -temp_id
				y_place_piece(from_x, from_y, second_x, second_y)
				update_piece_id_with_positions(from_x, from_y, second_x, second_y)
				if temp_id == 0:
					switch_turn()
					return
				from_id = temp_id
				from_x = second_x
				from_y = second_y
			else:
				return
		else:
			return
	elif from_y == second_y:
		if (xmoved and ymoved) and last_changed == "y":
			return
		if abs(from_x - second_x) <= abs(from_id):
			var expected_id = abs(from_id) - abs(from_x - second_x)
			move_possible(from_x, from_y, second_x, second_y, expected_id)
			if can_move:
				var temp_id = abs(from_id) - abs(from_x - second_x)
				if current_turn == Player.P_BLACK:
					temp_id = -temp_id
				x_place_piece(from_x, from_y, second_x, second_y)
				update_piece_id_with_positions(from_x, from_y, second_x, second_y)
				if temp_id == 0:
					switch_turn()
					return
				from_id = temp_id
				from_x = second_x
				from_y = second_y
			else:
				return
		else:
			return
	else:
		return


func move_possible(mp_from_x, mp_from_y, mp_to_x, mp_to_y, expected_id) -> void:
	can_move = true
	is_piece_zero = false
	var tile_x = mp_from_x
	var tile_y = mp_from_y
	if x_moving_direction == "+" and mp_from_x > mp_to_x:
		can_move = false
	if x_moving_direction == "-" and mp_from_x < mp_to_x:
		can_move = false
	if y_moving_direction == "+" and mp_from_y > mp_to_y:
		can_move = false
	if y_moving_direction == "-" and mp_from_y < mp_to_y:
		can_move = false
	if not can_move:
		return

	if mp_from_x == mp_to_x:
		var dir = 1 if mp_from_y < mp_to_y else -1
		for tiles in range(abs(mp_from_y - mp_to_y)):
			if tiles == abs(mp_from_y - mp_to_y) - 1:
				is_piece_zero = true
			tile_y += dir
			check_for_piece(tile_x, tile_y, expected_id)
			if not can_move:
				break
	else:
		var dir = 1 if mp_from_x < mp_to_x else -1
		for tiles in range(abs(mp_from_x - mp_to_x)):
			if tiles == abs(mp_from_x - mp_to_x) - 1:
				is_piece_zero = true
			tile_x += dir
			check_for_piece(tile_x, tile_y, expected_id)
			if not can_move:
				break


func check_for_piece(tile_x, tile_y, expected_id) -> void:
	var ct = Globals.board[tile_x][tile_y]
	if ct != 0:
		if is_piece_zero and expected_id == 0:
			if current_turn == Player.P_BLACK and ct > 0:
				capture_piece(tile_x, tile_y)
				can_move = true
			elif current_turn == Player.P_WHITE and ct < 0:
				capture_piece(tile_x, tile_y)
				can_move = true
			else:
				can_move = false
		else:
			can_move = false
	else:
		can_move = true


func x_place_piece(x_from_x, x_from_y, x_to_x, _y) -> void:
	Globals.board[x_from_x][x_from_y] = 0
	xmoved = true
	last_changed = "x"
	Globals.waiting_for_first = false
	moved_sth = true
	if x_from_x < x_to_x:
		x_moving_direction = "+"
	elif x_from_x > x_to_x:
		x_moving_direction = "-"
	Globals.display_board()


func y_place_piece(y_from_x, y_from_y, _x, y_to_y) -> void:
	Globals.board[y_from_x][y_from_y] = 0
	ymoved = true
	last_changed = "y"
	Globals.waiting_for_first = false
	moved_sth = true
	if y_from_y < y_to_y:
		y_moving_direction = "+"
	elif y_from_y > y_to_y:
		y_moving_direction = "-"
	Globals.display_board()


func capture_piece(tile_x, tile_y) -> void:
	var piece = Globals.board[tile_x][tile_y]
	if abs(piece) == 10:
		black_wins = (piece == 10)
		game_over = true
		_send_state_to_server()
	Globals.board[tile_x][tile_y] = 0


func light_pieces_up(piece_id, tile_x, tile_y) -> void:
	if game_over:
		return
	pos_moves.clear()
	no_pos_moves.clear()
	var num: int
	if moved_sth:
		num = 1 if is_king_piece else abs(from_id)
	else:
		num = 1 if abs(piece_id) == 10 else abs(piece_id)
	check_light_up(tile_x, tile_y, num)


func check_light_up(tile_x, tile_y, remaining_moves) -> void:
	var cmx = true
	var cmy = true
	if xmoved and ymoved:
		if last_changed == "x":
			cmy = false
		elif last_changed == "y":
			cmx = false

	var dirs: Array = []
	if cmx and x_moving_direction != "-":
		dirs.append(Vector2i(1, 0))
	if cmx and x_moving_direction != "+":
		dirs.append(Vector2i(-1, 0))
	if cmy and y_moving_direction != "-":
		dirs.append(Vector2i(0, 1))
	if cmy and y_moving_direction != "+":
		dirs.append(Vector2i(0, -1))

	for d in dirs:
		for i in range(1, remaining_moves + 1):
			var nx = tile_x + d.x * i
			var ny = tile_y + d.y * i
			if nx < 0 or nx >= Globals.BOARD_SIZE or ny < 0 or ny >= Globals.BOARD_SIZE:
				break
			var tv = Globals.board[nx][ny]
			if tv == 0:
				pos_moves.append([nx, ny])
			elif i == remaining_moves:
				if (current_turn == Player.P_WHITE and tv < 0) or \
				   (current_turn == Player.P_BLACK and tv > 0):
					pos_moves.append([nx, ny])
				else:
					no_pos_moves.append([nx, ny])
				break
			else:
				no_pos_moves.append([nx, ny])
				break


func roll_forward(f):
	var t = f.top
	f.top = f.south
	f.south = f.bottom
	f.bottom = f.north
	f.north = t
	return f


func roll_backward(f):
	var t = f.top
	f.top = f.north
	f.north = f.bottom
	f.bottom = f.south
	f.south = t
	return f


func roll_right(f):
	var t = f.top
	f.top = f.west
	f.west = f.bottom
	f.bottom = f.east
	f.east = t
	return f


func roll_left(f):
	var t = f.top
	f.top = f.east
	f.east = f.bottom
	f.bottom = f.west
	f.west = t
	return f

func update_piece_id_with_positions(prev_x, prev_y, new_x, new_y) -> void:
	var key = str(prev_x) + "|" + str(prev_y)
	var new_key = str(new_x) + "|" + str(new_y)

	# If dice state is missing, create a default for the source position
	# to prevent nil access in animation scripts.
	if not Globals.dice_states.has(key):
		if abs(original_id) == 10:   # use original_id, not from_id (which may be 1)
			Globals.dice_states[key] = {
				"top": 10, "bottom": 10, "north": 10,
				"south": 10, "east": 10, "west": 10
			}
		else:
			# Use Globals' default dice creation
			var default_faces = Globals.create_default_dice_faces(abs(original_id))
			if current_turn == Player.P_BLACK:
				# Swap north/south and east/west for black orientation
				var temp = default_faces.north
				default_faces.north = default_faces.south
				default_faces.south = temp
				temp = default_faces.east
				default_faces.east = default_faces.west
				default_faces.west = temp
			Globals.dice_states[key] = default_faces

	var faces = Globals.dice_states[key]
	var dx = new_x - prev_x
	var dy = new_y - prev_y
	piece_moved.emit(prev_x, prev_y, dx, dy)

	if not is_king_piece:
		if dy > 0:
			for i in range(abs(dy)): roll_forward(faces)
		elif dy < 0:
			for i in range(abs(dy)): roll_backward(faces)
		elif dx > 0:
			for i in range(abs(dx)): roll_right(faces)
		elif dx < 0:
			for i in range(abs(dx)): roll_left(faces)

		var uid = faces.top
		if uid == 0:
			Debug.log("ERROR: faces.top is 0", Debug.TYPES.ERROR)
			return
		Globals.dice_states.erase(key)
		Globals.dice_states[new_key] = faces
		if current_turn == Player.P_BLACK:
			uid = -uid
		Globals.board[new_x][new_y] = uid
		from_id = uid
	else:
		var kid = -10 if current_turn == Player.P_BLACK else 10
		Globals.board[new_x][new_y] = kid
		Globals.dice_states.erase(key)
		Globals.dice_states[new_key] = faces
		from_id = 1

func backup_dice_states() -> void:
	dice_states_backup.clear()
	for key in Globals.dice_states.keys():
		var f = Globals.dice_states[key]
		dice_states_backup[key] = {
			"top": f.top, "bottom": f.bottom, "north": f.north,
			"south": f.south, "east": f.east, "west": f.west
		}

func restore_dice_states() -> void:
	Globals.dice_states.clear()
	for key in dice_states_backup.keys():
		var f = dice_states_backup[key]
		Globals.dice_states[key] = {
			"top": f.top, "bottom": f.bottom, "north": f.north,
			"south": f.south, "east": f.east, "west": f.west
		}
func hard_reset_manager() -> void:
	Globals.last_server_version = -1
	Globals.first_state_received = false

	current_turn = Player.P_WHITE
	game_over = false
	black_wins = false
	reset_turn_vars()
	pos_moves.clear()
	no_pos_moves.clear()
	dice_states_backup.clear()
	
