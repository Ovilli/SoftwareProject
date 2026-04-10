extends Node


func save_game(slot_id: int = 1) -> void:
	var saved_game := SavedGame.new()

	saved_game.board = Globals.board
	saved_game.dice_states = Globals.dice_states
	saved_game.equipped_skin = Globals.equipped_skin

	saved_game.current_turn = TurnMng.current_turn
	saved_game.my_player = TurnMng.my_player
	saved_game.game_over = TurnMng.game_over
	saved_game.last_changed = TurnMng.last_changed
	saved_game.x_moving_direction = TurnMng.x_moving_direction
	saved_game.y_moving_direction = TurnMng.y_moving_direction
	saved_game.movedxy = TurnMng.movedxy
	saved_game.ymoved = TurnMng.ymoved
	saved_game.xmoved = TurnMng.xmoved
	saved_game.moved_sth = TurnMng.moved_sth
	saved_game.is_piece_zero = TurnMng.is_piece_zero
	saved_game.can_move = TurnMng.can_move
	saved_game.pos_moves = TurnMng.pos_moves
	saved_game.no_pos_moves = TurnMng.no_pos_moves
	saved_game.from_x = TurnMng.from_x
	saved_game.from_y = TurnMng.from_y
	saved_game.from_id = TurnMng.from_id
	saved_game.overlay_x = TurnMng.overlay_x
	saved_game.overlay_y = TurnMng.overlay_y
	saved_game.original_x = TurnMng.original_x
	saved_game.original_y = TurnMng.original_y
	saved_game.original_id = TurnMng.original_id
	saved_game.dice_states_backup = TurnMng.dice_states_backup
	saved_game.black_wins = TurnMng.black_wins
	saved_game.is_animating = TurnMng.is_animating
	saved_game._move_made = TurnMng._move_made

	var path := "user://save_slot_%d.tres" % slot_id
	var error: int = ResourceSaver.save(saved_game, path)

	if error == OK:
		print("Game saved to slot ", slot_id)
	else:
		print("Error saving game: ", error)


func load_game(slot_id: int = 1) -> void:
	var path := "user://save_slot_%d.tres" % slot_id

	if not FileAccess.file_exists(path):
		print("No save file in slot ", slot_id)
		return

	var saved_game := load(path) as SavedGame

	if not saved_game:
		print("Failed to load save file")
		return

	Globals.board = saved_game.board
	Globals.dice_states = saved_game.dice_states
	Globals.equipped_skin = saved_game.equipped_skin

	TurnMng.current_turn = saved_game.current_turn
	TurnMng.my_player = saved_game.my_player
	TurnMng.game_over = saved_game.game_over
	TurnMng.last_changed = saved_game.last_changed
	TurnMng.x_moving_direction = saved_game.x_moving_direction
	TurnMng.y_moving_direction = saved_game.y_moving_direction
	TurnMng.movedxy = saved_game.movedxy
	TurnMng.ymoved = saved_game.ymoved
	TurnMng.xmoved = saved_game.xmoved
	TurnMng.moved_sth = saved_game.moved_sth
	TurnMng.is_piece_zero = saved_game.is_piece_zero
	TurnMng.can_move = saved_game.can_move
	TurnMng.pos_moves = saved_game.pos_moves
	TurnMng.no_pos_moves = saved_game.no_pos_moves
	TurnMng.from_x = saved_game.from_x
	TurnMng.from_y = saved_game.from_y
	TurnMng.from_id = saved_game.from_id
	TurnMng.overlay_x = saved_game.overlay_x
	TurnMng.overlay_y = saved_game.overlay_y
	TurnMng.original_x = saved_game.original_x
	TurnMng.original_y = saved_game.original_y
	TurnMng.original_id = saved_game.original_id
	TurnMng.dice_states_backup = saved_game.dice_states_backup
	TurnMng.black_wins = saved_game.black_wins
	TurnMng.is_animating = saved_game.is_animating
	TurnMng._move_made = saved_game._move_made

	print("Game loaded from slot ", slot_id)


func delete_save(slot_id: int) -> void:
	var path := "user://save_slot_%d.tres" % slot_id

	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Deleted save slot ", slot_id)


func get_existing_slots() -> Array[int]:
	var slots: Array[int] = []

	for i in range(1, 10):
		if FileAccess.file_exists("user://save_slot_%d.tres" % i):
			slots.append(i)

	return slots

func get_save_info(slot_id: int) -> Dictionary:
	var path := "user://save_slot_%d.tres" % slot_id

	if not FileAccess.file_exists(path):
		return {}

	var modified_time: int = FileAccess.get_modified_time(path)
	var datetime: String = Time.get_datetime_string_from_unix_time(modified_time)

	return { "time": datetime }
