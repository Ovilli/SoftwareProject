extends Node

@onready var tutorial_layer: CanvasLayer = $TutorialLayer
@onready var help: Label = $TutorialLayer/Label
@onready var label_level: Label = $TutorialLayer/level

var level : int = 1
var board_tutorial : Array = []
var tutorial_running := false
var turn_counter: int
func _ready():
	tutorial_layer.hide()
	
func _process(_delta):
	if Globals.how_to_open:
		tutorial_layer.show()
		label_level.text = str(level)
		if !tutorial_running:
			if level == 1:
				tutorial_1()
				help.text = "Move the White-5 onto the \nBlack King to win the game!!"
				tutorial_running = true
			elif level == 2:
				tutorial_2()
				help.text = ""
				tutorial_running = true
		reset_tutorial()

func tutorial_1():
	turn_counter = 2
	board_tutorial.clear()
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([10,0,0,5,0,0,0,0,-10])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	Globals.board = board_tutorial.duplicate(true)
	Globals.display_board()
	
func tutorial_2():
	turn_counter = 3
	board_tutorial.clear()
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,2,0,0])
	board_tutorial.append([0,0,0,0,0,-6,0,0,0])
	board_tutorial.append([10,0,0,0,0,0,0,0,-10])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	Globals.board = board_tutorial.duplicate(true)
	Globals.display_board()

func reset_tutorial():
	if !TurnMng.game_over and turn_counter == Globals.counter:
		if TurnMng.current_turn == TurnMng.Player.P_BLACK:
			TurnMng.hard_reset_manager()
			Globals.counter = 1
			#set label text to help and reset board_state
			if level == 1:
				help.text = "Please try again!\nclick on the White-5 \nthen on the Black-King"
				tutorial_1()
			if level == 2:
				help.text = ""
				tutorial_2()
	elif turn_counter != Globals.counter and TurnMng.current_turn == TurnMng.Player.P_BLACK:
		TurnMng.hard_reset_manager()
		Globals.display_board()
	elif TurnMng.game_over:
		TurnMng.hard_reset_manager()
		tutorial_running = false
		Globals.display_board()
		level += 1
		
		
		
		
		
		
		
func _on_next_pressed() -> void:
	level += 1
	tutorial_running = false
	
	#TODO: adding more tutorials
	#TODO: adding text to tutorial 2
