extends Node

@onready var tutorial_layer: CanvasLayer = $TutorialLayer
@onready var help: Label = $TutorialLayer/Label
@onready var label_level: Label = $TutorialLayer/level
@onready var given_moves_label: Label = $TutorialLayer/GivenMoves

var level : int = 1
var max_levels := 3
var board_tutorial : Array = []
var tutorial_running := false
var turn_based : bool
var turn_counter: int
var given_moves: int
func _ready():
	tutorial_layer.hide()
	
func _process(_delta):
	if Globals.how_to_open and Windowmng.is_not_open(Windowmng.Screen.QUIT) and Windowmng.is_not_open(Windowmng.Screen.OPTIONS):
		tutorial_layer.show()
		label_level.text = str(level)
		if !tutorial_running:
			Globals.clear_move_markers()
			if level == 1:
				tutorial_1()
				help.text = "This game is turn-based.\nIn this Tutorial you can do moves in a row\n\nClick on the table to go into board view\nescape with `Esc`\nMove the White-5 onto the\nBlack King to win the game!!"
				tutorial_running = true
			elif level == 2:
				tutorial_2()
				help.text = "Your opponent is attacking your King\nyou can move your piece straight\nor turn once.\nMove your White-2 to save your King\n\nNormal-Pieces rotate as they move\nMove so you attack the Black-King"
				tutorial_running = true
			elif level == 3:
				tutorial_3()
				help.text = "Now we get to a little gameplay-simulation\nin this case the Black will move to\n\nMove a piece so the Black-King\ncan not move to a save square\n\nIf you make a mistake during your move\nyou can reset presing `R` "
				tutorial_running = true
			else:
				Windowmng.open(Windowmng.Screen.MAIN_MENU)
				Globals.board_clear()
				Globals.dice_states.clear()
				TurnMng.reset_turn_vars()
				Globals.tisch_open = false
				TurnMng.game_over = false
				Globals.how_to_open = false
				get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
		reset_tutorial()
		given_moves_label.text = "Moves left: " + str(given_moves)
	else:
		tutorial_layer.hide()
func tutorial_1():
	Globals.counter = 1
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
	Globals.counter = 1
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
func tutorial_3():
	Globals.counter = 1
	turn_counter = 3
	turn_based = true
	board_tutorial.clear()
	board_tutorial.append([0,0,0,0,0,0,0,0,-10])
	board_tutorial.append([1,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,2,0])
	board_tutorial.append([10,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	board_tutorial.append([0,0,0,0,6,0,0,0,0])
	board_tutorial.append([0,0,0,0,0,0,0,0,0])
	Globals.board = board_tutorial.duplicate(true)
	Globals.display_board()
func reset_tutorial():
	given_moves = turn_counter - Globals.counter
	if !TurnMng.game_over and turn_counter == Globals.counter:
		if TurnMng.current_turn == TurnMng.Player.P_BLACK:
			TurnMng.hard_reset_manager()
			#set label text to help and reset board_state
			if level == 1:
				help.text = "Please try again!\nclick on the White-5 \nthen on the Black-King"
				tutorial_1()
			elif level == 2:
				help.text = "Okay, you´ve got this\nselect the White-2\nmove it once LEFT and once BACK\nNow you got your setup to win the game"
				tutorial_2()
			elif level == 3:
				help.text = "Just try again!\nMove a piece so the Black-King\ncan not move to a save square\n\nIf you make a mistake during your move\nyou can reset presing ´R´ "
				tutorial_3()
				
	elif turn_counter != Globals.counter and TurnMng.current_turn == TurnMng.Player.P_BLACK and !turn_based:
		TurnMng.hard_reset_manager()
		Globals.display_board()
	elif turn_counter != Globals.counter and TurnMng.current_turn == TurnMng.Player.P_BLACK and turn_based:
		if level == 3:
			TurnMng.legal_move(0, 8, -10, 1, 8)    #TurnMng.legal_move(first_x, first_y, first_id, second_x, second_y)
		else:
			pass
		TurnMng.hard_reset_manager()
		Globals.counter -= 1
	elif TurnMng.game_over:
		TurnMng.hard_reset_manager()
		tutorial_running = false
		Globals.display_board()
		if level + 1 <= max_levels + 1:
			level += 1
			turn_based = false
		
		
		
		
		
#BUTTONS--------------------------------------------------------------------------------------------

func _on_next_pressed() -> void:
	if level + 1 <= max_levels:
		level += 1
		tutorial_running = false
	

func _on_prev_pressed() -> void:
	if level >= 2:
		level -= 1
		tutorial_running = false
	#TODO: adding more tutorials
	#TODO: adding text to tutorial 2
	#TODO: lock kamera rotation in tutorial
	#TODO: animation of moving pieces
	#You could add puzzles through same way like tutorial_3 (with a little debugging on faces)^.^
