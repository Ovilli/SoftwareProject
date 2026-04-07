extends Node

const URL = "https://myhiddenserver-production.up.railway.app"

enum RequestType { NONE, GET, SEND, CREATE, DELETE, GAMES, JOIN, GET_PLAYERS }

# Used only to prevent overlapping SEND requests (POST /api/send).
var _send_in_flight: bool = false
var _queued_send: Dictionary = {}

# Optional callback fired once after the next SEND completes successfully.
var _on_send_complete: Callable = Callable()

# Signals
signal games_received(parsed)
signal game_created
signal game_joined(count)
signal player_joined(count)

# Reference to the game manager (TurnMng)
var game_manager: Node = null


func _ready() -> void:
	Debug.log("Sender is Up and Running ...")


func is_busy() -> bool:
	return _send_in_flight


func has_queued_send() -> bool:
	return not _queued_send.is_empty()


# ─────────────────────────────────────────────────────────────────────────────
# Public packet methods
# ─────────────────────────────────────────────────────────────────────────────

func packetSendDataList(data_to_send: Dictionary, on_complete: Callable = Callable()) -> void:
	if on_complete.is_valid():
		_on_send_complete = on_complete

	if _send_in_flight:
		_queued_send = data_to_send
		Debug.log("Send queued (request in flight)")
		return

	_do_send(data_to_send)


func packetGetDataList() -> void:
	_fire(URL + "/api/get/" + Globals.GAME_ID, HTTPClient.METHOD_GET)


func packetJoinGame() -> void:
	_fire(URL + "/api/join/" + Globals.GAME_ID,
		HTTPClient.METHOD_POST,
		JSON.stringify({"player_id": Globals.player_id}))


func packetGetPlayerCount() -> void:
	_fire(URL + "/api/players/" + Globals.GAME_ID, HTTPClient.METHOD_GET)


func packetSendGameCreate(data_to_send: Array) -> void:
	_fire(URL + "/api/create/" + Globals.GAME_ID,
		HTTPClient.METHOD_POST,
		JSON.stringify(data_to_send))


func packetSendDeleteGame() -> void:
	_fire(URL + "/api/delete/" + Globals.GAME_ID, HTTPClient.METHOD_DELETE)


func packetGameCheck() -> void:
	_fire(URL + "/api/games", HTTPClient.METHOD_GET)


# ─────────────────────────────────────────────────────────────────────────────
# Internal helpers
# ─────────────────────────────────────────────────────────────────────────────

func _do_send(data_to_send: Dictionary) -> void:
	_send_in_flight = true
	_fire(URL + "/api/send/" + Globals.GAME_ID,
		HTTPClient.METHOD_POST,
		JSON.stringify(data_to_send))
	Debug.log("SENDING to server - Turn: %s" % str(data_to_send.get("current_turn", "?")))


func _fire(url: String, method: int = HTTPClient.METHOD_GET, body: String = "") -> void:
	var http := HTTPRequest.new()
	add_child(http)

	# Store the request type for response handling
	var request_type = RequestType.NONE
	match method:
		HTTPClient.METHOD_GET:
			if url.ends_with("/games"):
				request_type = RequestType.GAMES
			elif "/players/" in url:
				request_type = RequestType.GET_PLAYERS
			elif "/get/" in url:
				request_type = RequestType.GET
		HTTPClient.METHOD_POST:
			if "/send/" in url:
				request_type = RequestType.SEND
			elif "/create/" in url:
				request_type = RequestType.CREATE
			elif "/join/" in url:
				request_type = RequestType.JOIN
		HTTPClient.METHOD_DELETE:
			request_type = RequestType.DELETE

	http.request_completed.connect(
		func(result, code, headers, resp_body):
			_on_request_completed(result, code, headers, resp_body, request_type)
			http.queue_free()
	)

	var headers = ["Content-Type: application/json"] if body != "" else []
	var err = http.request(url, headers, method, body)
	if err != OK:
		Debug.log("HTTPRequest.request() failed: %d" % err, Debug.TYPES.ERROR)
		if request_type == RequestType.SEND:
			_send_in_flight = false
		http.queue_free()


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray,
		body: PackedByteArray, request_type: RequestType) -> void:

	# If this was a SEND, mark it as no longer in flight.
	var was_send = (request_type == RequestType.SEND)
	if was_send:
		_send_in_flight = false

	if result != HTTPRequest.RESULT_SUCCESS:
		Debug.log("HTTP request failed: result=%d code=%d" % [result, response_code], Debug.TYPES.ERROR)
		# If a SEND failed and there's a queued send, process it now.
		if was_send and not _queued_send.is_empty():
			var payload = _queued_send
			_queued_send = {}
			_do_send(payload)
		return

	var text = body.get_string_from_utf8()
	if text.is_empty():
		Debug.log("Empty response body (request type %d)" % request_type, Debug.TYPES.WARN)
		return

	var json = JSON.new()
	var parse_error = json.parse(text)
	if parse_error != OK:
		Debug.log("JSON parse failed: %s" % json.get_error_message(), Debug.TYPES.ERROR)
		if was_send and not _queued_send.is_empty():
			var payload = _queued_send
			_queued_send = {}
			_do_send(payload)
		return

	var parsed = json.get_data()

	# If a GET response arrives while a SEND is queued, ignore it (stale data).
	if request_type == RequestType.GET and not _queued_send.is_empty():
		Debug.log("Ignoring stale GET response because a newer send is pending", Debug.TYPES.WARN)
		return

	match response_code:
		200, 201:
			match request_type:
				RequestType.GET:
					var ct = str(parsed.get("current_turn", "?")) if parsed is Dictionary else "?"
					Debug.log("GET response - current_turn: %s" % ct.to_upper())
					if game_manager != null and game_manager.has_method("_on_server_state_received"):
						game_manager._on_server_state_received(parsed)
					else:
						Debug.log("GET received but game_manager not set", Debug.TYPES.WARN)

				RequestType.SEND:
					# Unwrap if response contains a "game" object
					if parsed is Dictionary and parsed.has("game") and parsed["game"] is Dictionary:
						parsed = parsed["game"]
					if game_manager != null and game_manager.has_method("_on_server_state_received"):
						game_manager._on_server_state_received(parsed)
					Debug.log("State saved to server OK", Debug.TYPES.SUCCSESS)

					# Fire the post-send callback if registered
					if _on_send_complete.is_valid():
						var cb = _on_send_complete
						_on_send_complete = Callable()
						cb.call()

					# Process any queued send
					if not _queued_send.is_empty():
						var payload = _queued_send
						_queued_send = {}
						_do_send(payload)

				RequestType.CREATE:
					Debug.log("Game created: %s" % str(parsed))
					emit_signal("game_created")

				RequestType.DELETE:
					Debug.log("Game deleted")

				RequestType.GAMES:
					Debug.log("Active games: %s" % str(parsed))
					emit_signal("games_received", parsed)

				RequestType.JOIN:
					var count = int(parsed.get("count", 0)) if parsed is Dictionary else 0
					Debug.log("Joined game, players: %d" % count)
					emit_signal("game_joined", count)

				RequestType.GET_PLAYERS:
					var count = int(parsed.get("count", 0)) if parsed is Dictionary else 0
					Debug.log("Player count: %d" % count)
					emit_signal("player_joined", count)

		404:
			Debug.log("404 Not found: %s" % str(parsed.get("error", "unknown") if parsed is Dictionary else parsed), Debug.TYPES.ERROR)
		409:
			Debug.log("409 Conflict: %s" % str(parsed.get("error", "unknown") if parsed is Dictionary else parsed), Debug.TYPES.ERROR)
		_:
			Debug.log("Unexpected HTTP %d: %s" % [response_code, str(parsed).left(200)], Debug.TYPES.WARN)
