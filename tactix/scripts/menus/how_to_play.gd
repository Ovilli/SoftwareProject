extends Control

#Variabels
var PAGE := 0
var PAGES := []

#Paths
@onready var canvas_layer: CanvasLayer = $"../Control/CanvasLayer"
@onready var play_canvas: CanvasLayer = $Play_Canvas

func _ready() -> void:
	# Collect pages dynamically
	PAGES.clear()

	# All children of Dieces
	var dieces := $Play_Canvas/Dieces
	for child in dieces.get_children():
		if child and child is Control:
			PAGES.append(child)

	# Board page
	var board := $Play_Canvas.get_node_or_null("Board")
	if board and board is Control:
		PAGES.append(board)
	else:
		print("Board node missing or not Control")

	# Ruels page
	var ruels := $Play_Canvas.get_node_or_null("Ruels")
	if ruels and ruels is Control:
		PAGES.append(ruels)
		
	_show_current_page()
	_sync_canvas_visibility()

func _process(_delta: float) -> void:
	_sync_canvas_visibility()

func _sync_canvas_visibility() -> void:
	if Globals.how_to_open:
		canvas_layer.hide()
		play_canvas.show()
		show()
	else:
		hide()
		canvas_layer.show()
		play_canvas.hide()

func _on_next_pressed() -> void:
	if PAGES.size() == 0:
		return
	PAGE += 1
	if PAGE >= PAGES.size():
		PAGE = 0
	_show_current_page()

func _show_current_page() -> void:
	if PAGES.size() == 0:
		return
	for page in PAGES:
		if page:
			page.hide()
	if PAGE >= 0 and PAGE < PAGES.size() and PAGES[PAGE]:
		PAGES[PAGE].show()

func _on_exit_pressed() -> void:
	Globals.how_to_open = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
