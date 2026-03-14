extends Node

enum Screen {
	NONE,
	OPTIONS,
	HOW_TO_PLAY,
	MAIN_MENU,
	CREDITS,
	MULTI,
	SKINS
}

var current: Screen = Screen.NONE
var previous: Screen = Screen.NONE

const EFFECT = preload("uid://dontb43nxxubn")

signal window_changed(from: Screen, to: Screen)

func open(w: Screen) -> void:
	if current == w:
		return
	
	previous = current
	current = w
	window_changed.emit(previous, current)
	play_effect()
func close() -> void:
	open(previous)
	play_effect()
	

func is_open(w: Screen) -> bool:
	return current == w

func is_not_open(w: Screen) -> bool:
	return current != w


func play_effect() -> void:
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = EFFECT
	player.pitch_scale = randf_range(0.9, 1.1)
	player.play()
	player.finished.connect(player.queue_free)
