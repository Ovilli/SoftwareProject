extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var saved_games: ItemList = $CanvasLayer/SavedGames
@onready var close: Button = $CanvasLayer/Close
@onready var delete: Button = $CanvasLayer/Delete
@onready var load: Button = $CanvasLayer/Load
@onready var label: Label = $CanvasLayer/Label

func _process(delta: float) -> void:
	if Windowmng.is_open(Windowmng.Screen.SAVELOAD):
		canvas_layer.show()
	else:
		canvas_layer.hide()

func _ready() -> void:
	refresh_save_list()

func refresh_save_list() -> void:
	saved_games.clear()
	var slots: Array[int] = SaveLoadGame.get_existing_slots()
	if slots.is_empty():
		saved_games.add_item("No saved games found")
		saved_games.set_item_disabled(0, true)
		return
	for slot in slots:
		var info: Dictionary = SaveLoadGame.get_save_info(slot)
		var display_text := "Slot %d - %s" % [slot, info.get("time", "Unknown")]
		saved_games.add_item(display_text)
		var index: int = saved_games.get_item_count() - 1
		saved_games.set_item_metadata(index, slot)

func _on_load_pressed() -> void:
	Globals.game_loaded = true
	var selected_items: PackedInt32Array = saved_games.get_selected_items()
	if selected_items.is_empty():
		label.text = "Please select a save slot."
		return
	var index: int = selected_items[0]
	var slot_id: int = int(saved_games.get_item_metadata(index))
	SaveLoadGame.load_game(slot_id)
	print(Globals.board)
	get_tree().change_scene_to_file("res://scenes/game/main_game.tscn")

func _on_delete_pressed() -> void:
	var selected_items: PackedInt32Array = saved_games.get_selected_items()
	if selected_items.is_empty():
		label.text = "Please select a save slot to delete."
		return
	var index: int = selected_items[0]
	var slot_id: int = int(saved_games.get_item_metadata(index))
	SaveLoadGame.delete_save(slot_id)
	refresh_save_list()
	label.text = "Save deleted."

func _on_close_pressed() -> void:
	Windowmng.open(Windowmng.previous)
