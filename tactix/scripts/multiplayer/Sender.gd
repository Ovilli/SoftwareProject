extends Node

const URL = "https://myhiddenserver-production.up.railway.app"
var _http: HTTPRequest
var _is_requesting: bool = false

enum RequestType {NONE, GET, SEND, CREATE, DELETE, GAMES, JOIN, GET_PLAYERS}
var _last_request: RequestType = RequestType.NONE

signal games_received(parsed)
signal game_created
signal game_joined(count)
signal player_joined(count)

@onready var game_manager: Node = get_parent()

func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)
	Debug.log("Sender is Up and Running ...")

func packetSendDataList(data_to_send: Dictionary) -> void:
	if _is_requesting:
		return
	_is_requesting = true
	var url = URL + "/api/send/" + Globals.GAME_ID
	var json = JSON.stringify(data_to_send)
	var headers = ["Content-Type: application/json"]
	_last_request = RequestType.SEND
	_http.request(url, headers, HTTPClient.METHOD_POST, json)

func packetGetDataList() -> void:
	if _is_requesting:
		return
	_is_requesting = true
	_last_request = RequestType.GET
	_http.request(URL + "/api/get/" + Globals.GAME_ID)

func packetJoinGame() -> void:
	if _is_requesting:
		return
	_is_requesting = true
	var url = URL + "/api/join/" + Globals.GAME_ID
	var json = JSON.stringify({"player_id": Globals.player_id})
	var headers = ["Content-Type: application/json"]
	_last_request = RequestType.JOIN
	_http.request(url, headers, HTTPClient.METHOD_POST, json)

func packetGetPlayerCount() -> void:
	if _is_requesting:
		return
	_is_requesting = true
	_last_request = RequestType.GET_PLAYERS
	_http.request(URL + "/api/players/" + Globals.GAME_ID)

func packetSendGameCreate(data_to_send: Array) -> void:
	if _is_requesting:
		return
	_is_requesting = true
	var url = URL + "/api/create/" + Globals.GAME_ID
	var json = JSON.stringify(data_to_send)
	var headers = ["Content-Type: application/json"]
	_last_request = RequestType.CREATE
	_http.request(url, headers, HTTPClient.METHOD_POST, json)

func packetSendDeleteGame() -> void:
	if _is_requesting:
		return
	_is_requesting = true
	_last_request = RequestType.DELETE
	_http.request(URL + "/api/delete/" + Globals.GAME_ID, [], HTTPClient.METHOD_DELETE)

func packetGameCheck() -> void:
	if _is_requesting:
		return
	_is_requesting = true
	_last_request = RequestType.GAMES
	_http.request(URL + "/api/games")

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_is_requesting = false
	if result != HTTPRequest.RESULT_SUCCESS:
		Debug.log("HTTP Request failed: %d" % result)
		return
	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if parsed == null:
		Debug.log("Failed to parse JSON response")
		return
	match response_code:
		200, 201:
			match _last_request:
				RequestType.GET:
					game_manager._on_server_state_received(parsed)
				RequestType.SEND:
					Debug.log("State saved to server")
				RequestType.CREATE:
					Debug.log("Game created: %s" % str(parsed))
					emit_signal("game_created")
				RequestType.DELETE:
					Debug.log("Game deleted")
				RequestType.GAMES:
					Debug.log("Active games: %s" % str(parsed))
					emit_signal("games_received", parsed)
				RequestType.JOIN:
					var count = parsed.get("count", 0)
					Debug.log("Joined game, players: %d" % count)
					emit_signal("game_joined", count)
				RequestType.GET_PLAYERS:
					var count = parsed.get("count", 0)
					Debug.log("Player count: %d" % count)
					emit_signal("player_joined", count)
		404:
			Debug.log("Not found: %s" % str(parsed.get("error", "unknown")))
		409:
			Debug.log("Conflict: %s" % str(parsed.get("error", "unknown")))
		_:
			Debug.log("Unexpected code %d: %s" % [response_code, str(parsed)])
	_last_request = RequestType.NONE
