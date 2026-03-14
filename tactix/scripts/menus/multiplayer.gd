extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var ui: Control = $CanvasLayer/Ui
@onready var ui_multi: Control = $CanvasLayer/UiMulti
@onready var sender: Node = $DataSender
@onready var game: Control = $CanvasLayer/Game
@onready var messager: Label = $CanvasLayer/Game/Messager
@onready var data: ItemList = $CanvasLayer/Game/Data
@onready var button: Button = $CanvasLayer/UiMulti/Button
@onready var line_edit: LineEdit = $CanvasLayer/UiMulti/LineEdit

var lobby_timer: Timer
var _pending_create: bool = false

func _ready() -> void:
	canvas_layer.hide()

	Windowmng.window_changed.connect(_on_window_changed)
	_update_visibility()

	sender.games_received.connect(_on_games_received)
	sender.game_created.connect(_on_game_created)
	sender.game_joined.connect(_on_game_joined)
	sender.player_joined.connect(_on_player_joined)

func _on_window_changed(_from, _to):
	_update_visibility()

func _update_visibility():
	if Windowmng.is_open(Windowmng.Screen.MULTI):
		canvas_layer.show()
		ui.show()
		ui_multi.hide()
		game.hide()
	else:
		canvas_layer.hide()

func _on_multiplayer_btn_pressed():
	ui.hide()
	ui_multi.show()

func _on_singelplayer_pressed():
	get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")

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
	call_deferred("_send_join")

func _on_button_pressed():
	line_edit.editable = false
	button.disabled = true
	_pending_create = true
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
	call_deferred("_send_create")

func _send_create():
	sender.packetSendGameCreate(Globals.board)

func _on_game_created():
	Globals.player_id = "player_1"
	call_deferred("_send_join")

func _send_join():
	sender.packetJoinGame()

func gamelobby():
	ui.hide()
	ui_multi.hide()
	game.show()

	canvas_layer.show()

	data.set_item_text(3, str(Globals.GAME_ID))
	messager.text = "Waiting for opponent..."

	start_lobby_poll()

func start_lobby_poll():
	if lobby_timer:
		lobby_timer.stop()
		lobby_timer.queue_free()

	lobby_timer = Timer.new()
	add_child(lobby_timer)

	lobby_timer.wait_time = 2.0
	lobby_timer.timeout.connect(_poll_lobby)
	lobby_timer.start()

func _poll_lobby():
	sender.packetGetPlayerCount()

func _on_player_joined(count: int):
	if count >= 2:
		lobby_timer.stop()
		messager.text = "Game starting!"
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")
	else:
		messager.text = "Waiting for opponent... (%d/2)" % count

func _on_game_joined(count: int):
	if count >= 2:
		messager.text = "Game starting!"
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")
	else:
		gamelobby()

func _generate_unique_id(existing_ids: Dictionary) -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var candidate := ""
	var attempts := 0
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
	Debug.log(Globals.GAME_ID)
