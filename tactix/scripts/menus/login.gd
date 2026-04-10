extends Control

@onready var username_input: LineEdit = $CanvasLayer/Login/Username
@onready var password_input: LineEdit = $CanvasLayer/Login/Password
@onready var submit_button: Button = $CanvasLayer/Login/Submit
@onready var close_button: Button = $CanvasLayer/Close
@onready var error_label: Label = $CanvasLayer/ErrorLable
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var data_sender: Node = $DataSender

signal login_successful(player_data: Dictionary)
signal login_failed(reason: String)
signal login_cancelled

var is_request_pending: bool = false


func _ready() -> void:
	submit_button.pressed.connect(_on_submit_pressed)
	password_input.text_submitted.connect(_on_text_submitted)
	username_input.text_submitted.connect(_on_text_submitted)
	error_label.text = ""
	username_input.grab_focus()
	canvas_layer.hide()


func _process(delta: float) -> void:
	if Windowmng.is_open(Windowmng.Screen.LOGIN):
		canvas_layer.show()
	else:
		canvas_layer.hide()

func _on_text_submitted(_new_text: String) -> void:
	if not is_request_pending:
		_on_submit_pressed()


func _on_submit_pressed() -> void:
	if is_request_pending:
		return
	
	var user: String = username_input.text.strip_edges()
	var password: String = password_input.text
	
	if user.is_empty():
		_show_error("Username cannot be empty")
		return
	
	if password.length() < 4:
		_show_error("Password must be at least 4 characters")
		return
	
	_set_loading_state(true)
	error_label.text = ""
	_send_login_request(user, password)


func _send_login_request(username_str: String, password_str: String) -> void:
	if data_sender.has_method("authenticate"):
		if not data_sender.is_connected("login_success", _on_login_success):
			data_sender.connect("login_success", _on_login_success)
			data_sender.connect("login_error", _on_login_error)
		data_sender.authenticate(username_str, password_str)
		return
	
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_http_request_completed.bind(http))
	
	var url = "https://myhiddenserver-production.up.railway.app/api/auth/login"
	var body = JSON.stringify({
		"username": username_str,
		"password": password_str
	})
	var headers = ["Content-Type: application/json"]
	var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		_show_error("Connection failed. Please try again.")
		_set_loading_state(false)
		http.queue_free()


func _on_http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http_node: HTTPRequest) -> void:
	http_node.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		_show_error("Network error. Check your connection.")
		_set_loading_state(false)
		return
	
	if response_code != 200:
		var json = JSON.new()
		var error_msg = "Invalid credentials"
		if json.parse(body.get_string_from_utf8()) == OK:
			var data = json.get_data()
			if data is Dictionary and data.has("error"):
				error_msg = data["error"]
		_show_error(error_msg)
		_set_loading_state(false)
		return
	
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		_show_error("Invalid server response")
		_set_loading_state(false)
		return
	
	var data = json.get_data()
	_handle_login_success(data)


func _on_login_success(player_data: Dictionary) -> void:
	_handle_login_success(player_data)


func _on_login_error(error_message: String) -> void:
	_show_error(error_message)
	_set_loading_state(false)


func _handle_login_success(player_data: Dictionary) -> void:
	if player_data.has("token"):
		Globals.auth_token = player_data["token"]
	if player_data.has("player_id"):
		Globals.player_id = player_data["player_id"]
	if player_data.has("username"):
		Globals.username = player_data["username"]
	
	Debug.log("Login successful: %s" % Globals.username, Debug.TYPES.SUCCSESS)
	
	_set_loading_state(false)
	password_input.text = ""
	
	login_successful.emit(player_data)
	queue_free()


func _show_error(message: String) -> void:
	error_label.text = message
	error_label.add_theme_color_override("font_color", Color.RED)
	Debug.log("Login error: " + message, Debug.TYPES.WARN)


func _set_loading_state(is_loading: bool) -> void:
	is_request_pending = is_loading
	submit_button.disabled = is_loading
	username_input.editable = not is_loading
	password_input.editable = not is_loading
	
	if is_loading:
		submit_button.text = "Logging in..."
	else:
		submit_button.text = "Login"


func _on_close_pressed() -> void:
	login_cancelled.emit()
	Windowmng.open(Windowmng.previous)
