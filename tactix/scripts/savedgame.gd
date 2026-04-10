class_name SavedGame
extends Resource

@export var board: Array
@export var dice_states: Dictionary
@export var equipped_skin: int
@export var current_turn: TurnMng.Player
@export var my_player: TurnMng.Player
@export var game_over: bool
@export var last_changed: String
@export var x_moving_direction: String
@export var y_moving_direction: String
@export var movedxy: bool
@export var ymoved: bool
@export var xmoved: bool
@export var moved_sth: bool
@export var is_piece_zero: bool
@export var can_move: bool
@export var pos_moves: Array
@export var no_pos_moves: Array
@export var from_x: int
@export var from_y: int
@export var from_id: int
@export var overlay_x: int
@export var overlay_y: int
@export var original_x: int
@export var original_y: int
@export var original_id: int
@export var dice_states_backup: Dictionary
@export var black_wins: bool
@export var is_animating: bool
@export var _move_made: bool
