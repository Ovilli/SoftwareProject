extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var ui: Control = $CanvasLayer/Ui
@onready var ui_multi: Control = $CanvasLayer/UiMulti
@onready var game: Control = $CanvasLayer/Game
@onready var messager: Label = $CanvasLayer/Game/Messager
@onready var data: ItemList = $CanvasLayer/Game/Data
@onready var button: Button = $CanvasLayer/UiMulti/Button
@onready var line_edit: LineEdit = $CanvasLayer/UiMulti/LineEdit
@onready var ui_single: Control = $CanvasLayer/UiSingle

var sender: Node

var is_creator: bool = false
var lobby_timer: Timer
var _pending_create: bool = false

func _ready() -> void:
	sender = Sender
	if sender == null:
		Debug.log("Sender not Found",Debug.TYPES.ERROR)
		return

	canvas_layer.hide()
	Windowmng.window_changed.connect(_on_window_changed)
	_update_visibility()

	sender.games_received.connect(_on_games_received)
	sender.game_created.connect(_on_game_created)
	sender.game_joined.connect(_on_game_joined)
	sender.player_joined.connect(_on_player_joined)

	Debug.log("Lobby ready, Sender connected", Debug.TYPES.SUCCSESS)

func _on_window_changed(_from, _to):
	_update_visibility()

func _update_visibility():
	if Windowmng.is_open(Windowmng.Screen.MULTI):
		canvas_layer.show()
		ui.show()
		ui_multi.hide()
		ui_single.hide()
		game.hide()
	else:
		canvas_layer.hide()

func _on_multiplayer_btn_pressed():
	ui.hide()
	ui_multi.show()
	ui_single.hide()

func _on_singelplayer_pressed():
	game.hide()
	ui_multi.hide()
	ui.hide()
	ui_single.show()
	

func _on_exit_pressed():
	Windowmng.open(Windowmng.Screen.MAIN_MENU)

func _on_quit_pressed():
	get_tree().quit()

func _on_line_edit_text_changed(new_text: String):
	Globals.GAME_ID = new_text

func _on_line_edit_text_submitted(new_text: String):
	Globals.GAME_ID = new_text
	button.disabled = true
	line_edit.editable = false
	Globals.player_id = "player_2"
	Globals.multiplayer_enabeld = true
	Debug.log("Joining game: %s as player_2" % Globals.GAME_ID, Debug.TYPES.NONE)
	call_deferred("_send_join")

func _on_button_pressed():
	if sender == null:
		push_error("Lobby: sender is null, cannot create game")
		return
	line_edit.editable = false
	button.disabled = true
	_pending_create = true
	Debug.log("Requesting game list...", Debug.TYPES.NONE)
	sender.packetGameCheck()

func _on_games_received(parsed):
	if not _pending_create:
		return
	_pending_create = false

	var existing_ids: Dictionary = {}
	var games_list = []

	if parsed is Dictionary and parsed.has("games"):
		games_list = parsed["games"]
	elif parsed is Array:
		games_list = parsed

	for entry in games_list:
		if entry is Dictionary and entry.has("id"):
			existing_ids[entry["id"]] = true
		elif entry is String:
			existing_ids[entry] = true

	var new_id: String = _generate_unique_id(existing_ids)
	Globals.GAME_ID = new_id
	Debug.log("Generated new game ID: %s" % new_id, Debug.TYPES.SUCCSESS)
	call_deferred("_send_create")

func _send_create():
	Debug.log("Sending game create request for ID: %s" % Globals.GAME_ID, Debug.TYPES.NONE)
	sender.packetSendGameCreate(Globals.board)

func loadBoard():
	Globals.board.clear()
	Globals.board.append([5,  0, 0, 0, 0, 0, 0, 0, -5])
	Globals.board.append([1,  0, 0, 0, 0, 0, 0, 0, -1])
	Globals.board.append([2,  0, 0, 0, 0, 0, 0, 0, -2])
	Globals.board.append([6,  0, 0, 0, 0, 0, 0, 0, -6])
	Globals.board.append([10, 0, 0, 0, 0, 0, 0, 0, -10])
	Globals.board.append([6,  0, 0, 0, 0, 0, 0, 0, -6])
	Globals.board.append([2,  0, 0, 0, 0, 0, 0, 0, -2])
	Globals.board.append([1,  0, 0, 0, 0, 0, 0, 0, -1])
	Globals.board.append([5,  0, 0, 0, 0, 0, 0, 0, -5])


func _on_game_created():
	Debug.log("Game created callback received", Debug.TYPES.SUCCSESS)
	is_creator               = true
	Globals.player_id        = "player_1"
	Globals.multiplayer_enabeld = true

	loadBoard()
	print(Globals.board)

	var board_data: Array = []
	for x in range(Globals.BOARD_SIZE):
		var row: Array = []
		for y in range(Globals.BOARD_SIZE):
			row.append(Globals.board[x][y])
		board_data.append(row)

	var initial_state = {
		"board":        board_data,
		"dice_states":  {},
		"current_turn": "white",
		"winner":       null
	}

	Debug.log("Initial board state pushed to server", Debug.TYPES.NONE)

	sender.packetSendDataList(initial_state, _send_join)

func _send_join():
	Debug.log("Sending join request for game: %s as player: %s" \
		% [Globals.GAME_ID, Globals.player_id], Debug.TYPES.NONE)
	sender.packetJoinGame()

func gamelobby():
	Debug.log("Entering gamelobby, is_creator: %s" % str(is_creator), Debug.TYPES.SUCCSESS)
	ui.hide()
	ui_multi.hide()
	game.show()
	canvas_layer.show()
	data.set_item_text(3, str(Globals.GAME_ID))
	messager.text = "Waiting for opponent... (1/2)" if is_creator else "Waiting for opponent..."
	start_lobby_poll()

func start_lobby_poll():
	if lobby_timer:
		lobby_timer.stop()
		lobby_timer.queue_free()
		lobby_timer = null

	lobby_timer = Timer.new()
	add_child(lobby_timer)
	lobby_timer.wait_time = 2.0
	lobby_timer.timeout.connect(_poll_lobby)
	lobby_timer.start()
	Debug.log("Lobby polling started", Debug.TYPES.SUCCSESS)

func _poll_lobby():
	Debug.log("Polling player count for game: %s" % Globals.GAME_ID, Debug.TYPES.NONE)
	sender.packetGetPlayerCount()

func _on_player_joined(count: int):
	Debug.log("_on_player_joined: count = %d" % count, Debug.TYPES.NONE)
	if count >= 2:
		if lobby_timer:
			lobby_timer.stop()
		messager.text = "Game starting!"
		await get_tree().create_timer(1.0).timeout
		Debug.log("Starting game with player_id: %s, game_id: %s" % [Globals.player_id, Globals.GAME_ID], Debug.TYPES.NONE)
		get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")
		TurnMng.setup_for_session()
	else:
		messager.text = "Waiting for opponent... (%d/2)" % count

func _on_game_joined(count: int):
	Debug.log("_on_game_joined: count = %d, is_creator = %s" \
		% [count, str(is_creator)], Debug.TYPES.NONE)

	if is_creator:
		gamelobby()
	else:
		if count >= 2:
			messager.text = "Game starting!"
			await get_tree().create_timer(1.0).timeout
			Debug.log("Starting game with player_id: %s, game_id: %s" % [Globals.player_id, Globals.GAME_ID], Debug.TYPES.NONE)
			get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")
			TurnMng.setup_for_session()
		else:
			gamelobby()

func _generate_unique_id(existing_ids: Dictionary) -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var candidate := ""
	var attempts  := 0
	const MAX_ATTEMPTS := 100
	while attempts < MAX_ATTEMPTS:
		candidate = str(rng.randi_range(100000, 999999))
		if not existing_ids.has(candidate):
			return candidate
		attempts += 1
	push_warning("Could not find unique ID in %d attempts" % MAX_ATTEMPTS)
	return candidate

func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(Globals.GAME_ID)
	Debug.log("Copied game ID: %s" % Globals.GAME_ID, Debug.TYPES.NONE)


func _on_load_games_pressed() -> void:
	Windowmng.open(Windowmng.Screen.SAVELOAD)


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")


func _on_close_pressed() -> void:
	Windowmng.open(Windowmng.Screen.MAIN_MENU)
	
