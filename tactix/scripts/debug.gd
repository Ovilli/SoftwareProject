extends Node

enum TYPES {
	WARN,
	ERROR,
	SUCCSESS,
	NONE
}

const MAX_TRACKED: int = 5
const MIN_DUPLICATE_INTERVAL_MS: int = 1000

var _recent: Array = []

func log(msg, type = TYPES.NONE) -> void:
	if not Globals.DEBUG:
		return

	var current_time = Time.get_ticks_msec()
	var msg_str = str(msg)


	for entry in _recent:
		if entry["msg"] == msg_str:
			if (current_time - entry["time"]) < MIN_DUPLICATE_INTERVAL_MS:
				return
			else:
				entry["time"] = current_time
				_print(msg_str, type)
				return
	_recent.append({"msg": msg_str, "time": current_time})
	if _recent.size() > MAX_TRACKED:
		_recent.pop_front()

	_print(msg_str, type)

func _print(msg: String, type) -> void:
	var prefix = Globals.player_id + " " if Globals.player_id != "" else ""
	match type:
		TYPES.ERROR:
			print_rich(prefix + "[color=CRIMSON][b]ERROR:[/b][/color] " + msg)
		TYPES.WARN:
			print_rich(prefix + "[color=YELLOW][b]WARN:[/b][/color]  " + msg)
		TYPES.SUCCSESS:
			print_rich(prefix + "[color=GREEN][b]OK:[/b][/color]    " + msg)
		_:
			print_rich(prefix + "[color=GRAY][b]DBG:[/b][/color]   " + msg)
