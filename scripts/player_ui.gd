extends Control

@onready var rng = RandomNumberGenerator.new()
@onready var enemy = get_tree().current_scene.get_node("enemy")  # change if your node name is different

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$pause_menu.visible = false
	$settings.visible = false
	$Controls.visible = false
	
func play_interact():
	$interact.play()

func main_menu():
	$interact.play()
	await get_tree().create_timer(0.5, true).timeout
	get_tree().paused = false
	$pause_menu.visible = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func open_settings():
	$interact.play()
	$pause_menu.visible = false
	$settings.visible = true

func open_controls():
	$interact.play()
	$pause_menu.visible = false
	$Controls.visible = true

func close_menus():
	$interact.play()
	$settings.visible = false
	$Controls.visible = false
	$pause_menu.visible = true

func play_hover():
	$hover.play()

func resume_game():
	$interact.play()
	get_tree().paused = false
	$pause_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func restart_game():
	$interact.play()
	get_tree().paused = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	get_tree().reload_current_scene()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)

func quit_game():
	$interact.play()
	$pause_menu.visible = false
	$are_you_sure.visible = true

func confirm_yes():
	$interact.play()
	await get_tree().create_timer(0.5, true).timeout
	get_tree().quit()
	
func confirm_no():
	$interact.play() 
	$settings.visible = false
	$are_you_sure.visible = false
	$pause_menu.visible = true

func _process(_delta: float) -> void:
	if enemy and enemy.killed:
		var audios = []
		# Safely check and add audio nodes/properties if they exist
		if enemy.get("chase_music"):
			audios.append(enemy.chase_music)
		if enemy.get("chase_music_final"):  # Assumed to be enemy.chase_music_final (fixed typo)
			audios.append(enemy.chase_music_final)
		if enemy.get("monster_growl"):
			audios.append(enemy.monster_growl)
		if enemy.get("monster_growl2"):
			audios.append(enemy.monster_growl2)
		if enemy.get("monster_scream"):
			audios.append(enemy.monster_scream)
		
		for audio in audios:
			if audio and audio.playing:
				audio.stop()
		
	if Input.is_action_just_pressed("pause") and !$settings.visible and !$ending.visible:
		$pause_menu.visible = !$pause_menu.visible
		get_tree().paused = $pause_menu.visible
		
		if get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if !get_tree().paused:
			$interact.play()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	


func close_leaderboard() -> void:
	$interact.play()
	$leaderboard.visible = false
	$ending.visible = true
	
	var background = $ending.get_node("ColorRect")

	background.color = Color(0, 0, 0)  # Example: semi-transparent black
	
	# show UI elements
	$ending.get_node("RichTextLabel").visible = true
	$ending.get_node("RichTextLabel2").visible = true
	$ending.get_node("play_again").visible = true
	$ending.get_node("Main Menu").visible = true
