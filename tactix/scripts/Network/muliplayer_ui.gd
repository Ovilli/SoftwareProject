extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var client: Button = $CanvasLayer/Client
@onready var server_button: Button = $CanvasLayer/Server
@onready var status_label: Label = $CanvasLayer/STATUS

func _ready() -> void:
	# Connect to network signals for feedback
	if NetworkHandler:
		NetworkHandler.multiplayer.connected_to_server.connect(_on_client_connected)
		NetworkHandler.multiplayer.connection_failed.connect(_on_client_connection_failed)

func _process(delta: float) -> void:
	if Globals.how_to_open == true or Globals.options_open == true or Globals.main_menu == true:
		hide()
		canvas_layer.hide()
	elif Globals.muliplayer_open == true:
		show()
		canvas_layer.show()
		_update_button_states()

func _update_button_states() -> void:
	# Disable buttons if already connected
	if NetworkHandler.peer != null:
		server_button.disabled = true
		client.disabled = true
	else:
		server_button.disabled = false
		client.disabled = false

func _on_exit_pressed() -> void:
	# Disconnect if connected
	if NetworkHandler.peer != null:
		NetworkHandler.disconnect_peer()
	
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	Globals.muliplayer_open = false

func _on_server_pressed() -> void:
	if NetworkHandler.peer != null:
		print("Already connected to a network!")
		if status_label:
			status_label.text = "Already connected!"
		return
	
	NetworkHandler.start_server()
	
	# Check if server started successfully
	if NetworkHandler.peer != null:
		get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")
	else:
		if status_label:
			status_label.text = "Failed to start server!"

func _on_client_pressed() -> void:
	if NetworkHandler.peer != null:
		print("Already connected to a network!")
		if status_label:
			status_label.text = "Already connected!"
		return
	
	if status_label:
		status_label.text = "Connecting..."
	
	client.disabled = true
	server_button.disabled = true
	
	NetworkHandler.start_client()
	# Don't change scene yet - wait for connection success/failure

func _on_client_connected() -> void:
	# Successfully connected to server
	get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")

func _on_client_connection_failed() -> void:
	# Failed to connect
	if status_label:
		status_label.text = "Connection failed! No server found."
	
	client.disabled = false
	server_button.disabled = false
	
	await get_tree().create_timer(1.0).timeout
	if status_label:
		status_label.text = ""
