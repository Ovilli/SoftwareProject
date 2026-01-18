extends MultiplayerSpawner

# Variabels
@export var player_scene: PackedScene
@export var spawn_points: Array[Node3D] = []
@export var use_random_spawn := true
var spawned_players: Dictionary = {} 
var spawn_queue: Array[int] = []

func _ready() -> void:
	spawn_path = get_parent().get_path()
	spawn_function = _custom_spawn
	
	if player_scene:
		add_spawnable_scene(player_scene.resource_path)
	spawned.connect(_on_spawned)
	add_to_group("player_spawner")

func _custom_spawn(data: Variant) -> Node:
	var peer_id = data as int
	
	if player_scene == null:
		return null
	
	if spawned_players.has(peer_id):
		print("Player already exists for peer ", peer_id, ", returning existing")
		return spawned_players[peer_id]
	
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	
	player.set_multiplayer_authority(peer_id)
	
	spawned_players[peer_id] = player
	
	var spawn_position = _get_spawn_position(peer_id)
	if player is Node3D:
		player.position = spawn_position
	elif player is Node2D:
		player.position = Vector2(spawn_position.x, spawn_position.z)
	
	print("Custom spawn for peer ", peer_id, " at position ", spawn_position, " with authority: ", peer_id)
	return player

func _on_spawned(node: Node) -> void:
	var peer_id = int(node.name)
	if not spawned_players.has(peer_id):
		spawned_players[peer_id] = node

func spawn_player(peer_id: int) -> Node:
	if spawned_players.has(peer_id):
		return spawned_players[peer_id]
	
	var existing = get_parent().get_node_or_null(str(peer_id))
	if existing:
		existing.set_multiplayer_authority(peer_id)
		spawned_players[peer_id] = existing
		return existing
	
	var player = spawn(peer_id)
	
	if player:
		print("Player spawned for peer ", peer_id)
	
	return player

func _get_spawn_position(_peer_id: int) -> Vector3:
	print("Getting spawn position. spawn_points.size() = ", spawn_points.size(), ", spawned_players.size() = ", spawned_players.size())
	
	if spawn_points.is_empty():
		# Use number of spawned players for positioning
		var player_index = spawned_players.size()
		var offset = Vector3(player_index * 3.0, 1.0, 0)
		print("No spawn points defined, using offset: ", offset)
		return offset
	
	if use_random_spawn:
		var index = randi() % spawn_points.size()
		var pos = spawn_points[index].global_position
		print("Using random spawn point ", index, " at position: ", pos)
		return pos
	else:
		var player_count = spawned_players.size() - 1  # -1 because we already added current player
		var index = player_count % spawn_points.size()
		var pos = spawn_points[index].global_position
		print("Using sequential spawn point ", index, " at position: ", pos)
		return pos

func despawn_player(peer_id: int) -> void:
	if spawned_players.has(peer_id):
		var player = spawned_players[peer_id]
		if is_instance_valid(player):
			player.queue_free()
		spawned_players.erase(peer_id)
		print("Player despawned for peer ", peer_id)
	else:
		var player = get_parent().get_node_or_null(str(peer_id))
		if player:
			player.queue_free()
			print("Player despawned for peer ", peer_id)

func get_player(peer_id: int) -> Node:
	return spawned_players.get(peer_id, null)

func get_all_players() -> Array:
	return spawned_players.values()

func clear_all_players() -> void:
	for player in spawned_players.values():
		if is_instance_valid(player):
			player.queue_free()
	spawned_players.clear()
	print("All players cleared")
