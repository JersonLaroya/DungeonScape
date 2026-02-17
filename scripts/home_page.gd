extends Control

func _ready():
	# Fill input field with saved name
	var player_data = load_player_data()
	$CanvasLayer/player_name.text = player_data.name


func enter_game():
	play_interact()
	
	await get_tree().create_timer(0.2).timeout 
	var player_input = $CanvasLayer/player_name.text.strip_edges()
	if player_input == "":
		player_input = "Player"
		
	# TEMPORARY: Clear leaderboard so it's all new
	#var file = FileAccess.open("user://leaderboard.json", FileAccess.WRITE)
	#if file:
	#	file.store_string("[]")  # empty array
	#	file.close()

	# Save new player name
	save_player_data(player_input, 0)

	# Add to leaderboard list
	add_user_to_leaderboard(player_input, 0)

	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func play_hover():
	$hover.play()

func play_interact():
	$interact.play()

# -------- SAVE/LOAD SINGLE PLAYER DATA --------

func save_player_data(player_name: String, orbs: int):
	var save_data = {
		"name": player_name,
		"orbs": orbs
	}

	var file = FileAccess.open("user://player_data.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()


func load_player_data() -> Dictionary:
	var path = "user://player_data.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			file.close()
			if parsed is Dictionary:
				return parsed

	# Default if no file yet
	return { "name": "Player", "orbs": 0 }



# -------- LEADERBOARD STORAGE (ALL USERS) --------

func add_user_to_leaderboard(player_name: String, orbs: int):
	var list = load_leaderboard()

	# Check if player already exists → update orbs instead of duplicate
	for entry in list:
		if entry.name == player_name:
			entry.orbs = orbs
			save_leaderboard(list)
			return

	# Else → add new player
	list.append({ "name": player_name, "orbs": orbs })
	save_leaderboard(list)



func save_leaderboard(list: Array):
	var file = FileAccess.open("user://leaderboard.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(list))
		file.close()



func load_leaderboard() -> Array:
	var path = "user://leaderboard.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			file.close()
			if parsed is Array:
				return parsed
	return []
