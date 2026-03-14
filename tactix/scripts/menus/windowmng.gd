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

signal window_changed(from: Screen, to: Screen)

func open(w: Screen) -> void:
	if current == w:
		return
	
	previous = current
	current = w
	window_changed.emit(previous, current)

func close() -> void:
	open(previous)

func is_open(w: Screen) -> bool:
	return current == w

func is_not_open(w: Screen) -> bool:
	return current != w
