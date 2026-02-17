extends CanvasLayer

func _ready() -> void:
	set_checkbutton_setting("music", $music_button)
	set_checkbutton_setting("sfx", $sfx_button)
	set_option_setting("window_mode", $window_mode_options)


func set_checkbutton_setting(save_name, button):
	var file = FileAccess.open("user://" + save_name + ".dat", FileAccess.READ)
	if file:
		var val = file.get_as_text()
		button.button_pressed = (val == "true")
		file.close()
		# Apply the audio state immediately
		if save_name == "music":
			if button.button_pressed: enable_music()
			else: disable_music()
		elif save_name == "sfx":
			if button.button_pressed: enable_sfx()
			else: disable_sfx()


func set_option_setting(save_name, button):
	var file = FileAccess.open("user://" + save_name + ".dat", FileAccess.READ)
	if file:
		button.selected = int(file.get_as_text())
		file.close()
		set_window_mode(button.selected)


func save_setting(save_name: String, value):
	var file = FileAccess.open("user://" + save_name + ".dat", FileAccess.WRITE)
	file.store_string(str(value))
	file.close()


func set_window_mode(index):
	save_setting("window_mode", index)
	SettingsManager.window_mode = index
	SettingsManager.apply_window_mode()



func _on_music_check_toggled(pressed: bool) -> void:
	save_setting("music", pressed)
	if pressed: enable_music()
	else: disable_music()


func _on_sfx_check_toggled(pressed: bool) -> void:
	save_setting("sfx", pressed)
	if pressed: enable_sfx()
	else: disable_sfx()


func enable_music():
	var bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(bus, false)
	$music_button.text = "On"

func disable_music():
	var bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(bus, true)
	$music_button.text = "Off"

func enable_sfx():
	var bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(bus, false)
	$sfx_button.text = "On"

func disable_sfx():
	var bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(bus, true)
	$sfx_button.text = "Off"
	


func play_hover() -> void:
	pass # Replace with function body.


func play_interact() -> void:
	pass # Replace with function body.
