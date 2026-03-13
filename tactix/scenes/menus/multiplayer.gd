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
	Globals.multiplayer_enabeld = false
	Globals.multiplayer_menu = false
	Globals.multiplayer_lobby = false
	sender.games_received.connect(_on_games_received)
	sender.game_created.connect(_on_game_created)
	sender.game_joined.connect(_on_game_joined)
	sender.player_joined.connect(_on_player_joined)

func gamelobby() -> void:
	Globals.multiplayer_lobby = true
	canvas_layer.show()
	game.show()
	ui.hide()
	ui_multi.hide()
	data.set_item_text(3, str(Globals.GAME_ID))
	messager.text = "Waiting for opponent..."
	start_lobby_poll()

func start_lobby_poll() -> void:
	if lobby_timer:
		lobby_timer.stop()
		lobby_timer.queue_free()
	lobby_timer = Timer.new()
	add_child(lobby_timer)
	lobby_timer.wait_time = 2.0
	lobby_timer.timeout.connect(_poll_lobby)
	lobby_timer.start()

func _poll_lobby() -> void:
	Debug.log("Polling lobby...")
	sender.packetGetPlayerCount()

func _on_player_joined(count: int) -> void:
	Debug.log("Player count received: %d" % count)
	if count >= 2:
		lobby_timer.stop()
		messager.text = "Game starting!"
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")
	else:
		messager.text = "Waiting for opponent... (%d/2)" % count

func _process(_delta: float) -> void:
	if Globals.multiplayer_menu:
		canvas_layer.show()
		if not Globals.multiplayer_enabeld:
			ui.show()
			game.hide()
			ui_multi.hide()
		elif not Globals.multiplayer_lobby:
			ui.hide()
			game.hide()
			ui_multi.show()
		else:
			ui.hide()
			ui_multi.hide()
			game.show()

func _on_multiplayer_btn_pressed() -> void:
	Globals.multiplayer_enabeld = true
	Globals.multiplayer_menu = true
	canvas_layer.show()
	ui.hide()
	ui_multi.show()

func _on_singelplayer_pressed() -> void:
	Globals.multiplayer_enabeld = false
	get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")

func _on_line_edit_text_changed(new_text: String) -> void:
	Globals.GAME_ID = new_text

func _on_line_edit_text_submitted(new_text: String) -> void:
	Globals.GAME_ID = new_text
	Globals.multiplayer_enabeld = true
	button.disabled = true
	line_edit.editable = false
	Globals.player_id = "player_2"
	call_deferred("_send_join")

func _on_button_pressed() -> void:
	Globals.multiplayer_enabeld = true
	Globals.multiplayer_menu = true
	line_edit.editable = false
	button.disabled = true
	_pending_create = true
	sender.packetGameCheck()

func _on_games_received(parsed) -> void:
	if not _pending_create:
		return
	_pending_create = false
	Debug.log("Games response: %s" % str(parsed))
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
	Debug.log("Generated game ID: %s" % new_id)
	call_deferred("_send_create")

func _send_create() -> void:
	Debug.log("Sending create for ID: %s" % Globals.GAME_ID)
	sender.packetSendGameCreate(Globals.board)

func _on_game_created() -> void:
	Debug.log("Game created, joining as player_1...")
	Globals.player_id = "player_1"
	call_deferred("_send_join")

func _send_join() -> void:
	Debug.log("Joining game as: %s" % Globals.player_id)
	sender.packetJoinGame()

func _on_game_joined(count: int) -> void:
	Debug.log("_on_game_joined count: %d" % count)
	Globals.multiplayer_menu = true
	Globals.multiplayer_lobby = true
	if count >= 2:
		canvas_layer.show()
		game.show()
		ui.hide()
		ui_multi.hide()
		messager.text = "Game starting!"
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")
	else:
		gamelobby()

func _generate_unique_id(existing_ids: Dictionary) -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var candidate: String = ""
	var attempts: int = 0
	const MAX_ATTEMPTS = 100
	while attempts < MAX_ATTEMPTS:
		candidate = str(rng.randi_range(100000, 999999))
		if not existing_ids.has(candidate):
			return candidate
		attempts += 1
	push_warning("Could not find unique ID in %d attempts, using last candidate" % MAX_ATTEMPTS)
	return candidate


func _on_exit_pressed() -> void:
	Globals.multiplayer_enabeld = false
	Globals.multiplayer_lobby = false
	Globals.multiplayer_menu = false
	Globals.main_menu = true
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
