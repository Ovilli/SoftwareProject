@tool
extends EditorPlugin

const SHORTCUT_NAME = "Copy file:line"
const ACTION_NAME = "copy_file_line"

@export var shortcut_key: Key = KEY_C
@export var use_ctrl: bool = true
@export var use_shift: bool = true
@export var use_alt: bool = false

var _editor_interface: EditorInterface
var _script_editor: ScriptEditor

func _enter_tree() -> void:
	add_tool_menu_item(SHORTCUT_NAME, Callable(self, "_on_copy_file_line_pressed"))

	# Cache editor references
	_editor_interface = get_editor_interface()
	_script_editor = _editor_interface.get_script_editor()

	# Register shortcut action
	if not InputMap.has_action(ACTION_NAME):
		InputMap.add_action(ACTION_NAME)

	# Remove old events
	for event in InputMap.action_get_events(ACTION_NAME):
		InputMap.action_erase_event(ACTION_NAME, event)

	# Add new event with current settings
	var event := InputEventKey.new()
	event.keycode = shortcut_key
	event.ctrl_pressed = use_ctrl
	event.shift_pressed = use_shift
	event.alt_pressed = use_alt
	InputMap.action_add_event(ACTION_NAME, event)

func _exit_tree() -> void:
	remove_tool_menu_item(SHORTCUT_NAME)
	if InputMap.has_action(ACTION_NAME):
		InputMap.erase_action(ACTION_NAME)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_NAME):
		_on_copy_file_line_pressed()
		get_tree().root.set_input_as_handled()

func _on_copy_file_line_pressed() -> void:
	if not _script_editor:
		return

	var current_script := _script_editor.get_current_script()
	if not current_script or not current_script is Script:
		return

	var path := current_script.resource_path
	if path.is_empty():
		return

	var current_editor := _script_editor.get_current_editor()
	if not current_editor:
		return

	var code_edit := current_editor.get_base_editor() as CodeEdit
	if not code_edit:
		return

	var line := code_edit.get_caret_line() + 1
	var result := "%s:%d" % [path, line]
	DisplayServer.clipboard_set(result)
	print("Copied: ", result)
