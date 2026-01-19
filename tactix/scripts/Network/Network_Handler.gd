extends Node

#Variabels
const IP_ADDRESS := "127.0.0.1"
var PORT := 42069
const MAX_PLAYERS := 2
var player_names: Dictionary = {}

var peer: ENetMultiplayerPeer

@rpc("authority", "reliable")
func register_player_name(player_name: String) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	player_names[sender_id] = player_name
	print("Registered name:", player_name, "for peer:", sender_id)

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	
	if error != OK:
		print("Failed to create server: ", error)
		return
	
	multiplayer.multiplayer_peer = peer
	print("Server started on port ", PORT)
	
	# Wait for spawner to be ready, then spawn server player
	await get_tree().process_frame
	await get_tree().process_frame
	_spawn_player(multiplayer.get_unique_id())

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(IP_ADDRESS, PORT)
	
	if error != OK:
		print("Failed to create client: ", error)
		return
	
	multiplayer.multiplayer_peer = peer
	print("Client connecting to ", IP_ADDRESS, ":", PORT)

func _on_peer_connected(id: int) -> void:
	print("Peer connected: ", id)
	
	if not multiplayer.is_server():
		return
	
	# Small delay to ensure spawner is ready
	await get_tree().create_timer(0.1).timeout
	_spawn_player(id)

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: ", id)
	
	# Only server despawns
	if not multiplayer.is_server():
		return
		
	_remove_player(id)

func _on_connected_to_server() -> void:
	
	print("Successfully connected to server!")
	print("My peer ID: ", multiplayer.get_unique_id())
	register_player_name.rpc_id(1, Globals.player_name)

func _on_connection_failed() -> void:
	print("Connection to server failed!")
	peer = null

func _on_server_disconnected() -> void:
	print("Server disconnected!")
	peer = null

func _spawn_player(peer_id: int) -> void:
	var spawner = get_tree().get_first_node_in_group("player_spawner")
	
	if not spawner:
		print("ERROR: No spawner found in scene! Add a spawner node to 'player_spawner' group")
		return
	
	if not spawner.has_method("spawn_player"):
		print("ERROR: Spawner doesn't have a 'spawn_player' method!")
		return
	
	print("Spawning player for peer ID: ", peer_id)
	spawner.spawn_player(peer_id)

func _remove_player(peer_id: int) -> void:
	# First try using the spawner's despawn method
	var spawner = get_tree().get_first_node_in_group("player_spawner")
	if spawner and spawner.has_method("despawn_player"):
		spawner.despawn_player(peer_id)
		return
	
	# Fallback: Try multiple possible parent nodes
	var possible_parents = [
		get_tree().current_scene
	]
	
	for parent in possible_parents:
		var parent_node = get_node_or_null(parent) if parent is String else parent
		if parent_node:
			var player = parent_node.get_node_or_null(str(peer_id))
			if player:
				print("Removing player: ", peer_id)
				player.queue_free()
				return
	
	print("Player node not found for peer: ", peer_id)
	
func get_player_count() -> int:
	return multiplayer.get_peers().size() + (1 if multiplayer.multiplayer_peer else 0)

func disconnect_peer() -> void:
	if peer:
		peer.close()
		peer = null
		multiplayer.multiplayer_peer = null
		print("Disconnected from network")
