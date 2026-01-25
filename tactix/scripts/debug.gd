extends Node

var times = ""
var msg_old = ""

func check_duplicated(msg):
	if msg_old == msg:
		times += 1
	else:
		times = 0

func log(msg):
	if Globals.DEBUG:
		check_duplicated(msg)
		if times > 0:
			msg_old = msg
		else:
			print("DEBUG : " ,msg)
			msg_old = msg
