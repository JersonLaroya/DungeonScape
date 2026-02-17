extends Node

var window_mode := 1 # default fullscreen (matches your OptionButton index)

func _ready():
	load_window_mode()
	apply_window_mode()

func load_window_mode():
	var file = FileAccess.open("user://window_mode.dat", FileAccess.READ)
	if file:
		window_mode = int(file.get_as_text())
		file.close()

func apply_window_mode():
	if window_mode == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif window_mode == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
