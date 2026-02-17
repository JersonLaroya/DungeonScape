extends CharacterBody3D

@onready var player = get_tree().current_scene.get_node("player")
@onready var chasecasts = [
	$chasecast, $chasecast2, $chasecast3, $chasecast4, $chasecast5, $chasecast6, $chasecast7, $chasecast8, $chasecast9
]

@onready var endless_mode = get_parent().get_node("Endless Mode")
@onready var dungeon_lights: Array = [
	endless_mode.get_node("dungeon_light"),
	endless_mode.get_node("dungeon_light2"),
	endless_mode.get_node("dungeon_light3"),
	endless_mode.get_node("dungeon_light4"),
	endless_mode.get_node("dungeon_light5"),
	endless_mode.get_node("dungeon_light6"),
	endless_mode.get_node("dungeon_light7"),
	endless_mode.get_node("dungeon_light8")
]

@onready var ui = get_tree().current_scene.get_node("player/player_ui/leaderboard")
@onready var hud = endless_mode.get_node("HUD")  # HUD2 has orbs_collected

# Audio
@onready var chase_music: AudioStreamPlayer = $chase_music
@onready var monster_growl: AudioStreamPlayer3D = $monster_growl
@onready var jumpscare: AudioStreamPlayer = $jumpscare
@onready var spotlight = $monster/SpotLight3D

# Raycast kill camera
@onready var killcast_shape = $killcast/killcast

# Flicker settings
var lights_on: bool = true
var flicker_timer: float = 0.0
var flicker_interval: float = 0.1 
var flicker_distance: float = 20.0
var rng := RandomNumberGenerator.new()

# State
var chasing: bool = false
var killed: bool = false
var normal_speed := 15.0
var chase_speed := 20.0
var chase_timer: float = 0.0
var max_chase_time: float = 15.0
var ending_playing: bool = false  # Prevent multiple triggers

func _ready():
	monster_growl.play()
	for light in dungeon_lights:
		if light:
			light.visible = true
	if killcast_shape:
		killcast_shape.enabled = false


# ---------------- MAIN LOGIC ----------------
func _process(delta: float) -> void:
	if killed or ending_playing:
		return

	if monster_growl.stream != null and not monster_growl.playing:
		monster_growl.play()
		
	for ray in chasecasts:
		check_chase(ray)

	update_target_location()

	if chasing:
		if chase_music.stream != null and not chase_music.playing:
			chase_music.play()

		if chase_timer < max_chase_time:
			chase_timer += delta
		else:
			chasing = false
			chase_timer = 0.0
			if killcast_shape:
				killcast_shape.enabled = false
			if chase_music.playing:
				chase_music.stop()
		handle_chase_effects(delta)
	else:
		handle_idle_effects()


func handle_idle_effects():
	if chase_music.playing:
		chase_music.stop()
	for light in dungeon_lights:
		if light:
			light.visible = true


func handle_chase_effects(delta: float):
	flicker_timer += delta
	if flicker_timer >= 0.3:
		flicker_timer = 0.0
		for light in dungeon_lights:
			if light:
				light.visible = not light.visible


func check_chase(ray: RayCast3D):
	if ray.is_colliding():
		var hit = ray.get_collider()
		if hit.name == "player":
			chasing = true


# ---------------- PHYSICS ----------------
var stuck_timer := 0.0
var last_position := Vector3.ZERO
var stuck_check_interval := 0.5

func _physics_process(delta: float) -> void:
	if killed or ending_playing:
		return

	stuck_timer += delta
	if stuck_timer >= stuck_check_interval:
		stuck_timer = 0.0
		_check_if_stuck()

	var agent := $NavigationAgent3D
	var current_location = global_transform.origin
	var next_location = agent.get_next_path_position()

	if agent.is_navigation_finished() or current_location.distance_to(player.global_position) < 1.0:
		agent.target_position = player.global_position
		next_location = agent.get_next_path_position()

	var target_speed = chase_speed if chasing else normal_speed
	var direction = (next_location - current_location)

	if direction.length() < 0.1:
		direction = (player.global_position - current_location)

	var new_velocity = direction.normalized() * target_speed
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()

	if direction.length() > 0.01:
		var target_angle = atan2(-direction.x, -direction.z)
		var current_angle = deg_to_rad(global_rotation_degrees.y)
		var new_angle = lerp_angle(current_angle, target_angle, 0.25)
		global_rotation_degrees.y = rad_to_deg(new_angle)

	if chasing:
		kill_player()

	last_position = global_position


func _check_if_stuck():
	var distance_moved = global_position.distance_to(last_position)
	if distance_moved < 0.1:
		$NavigationAgent3D.target_position = player.global_position


func update_target_location():
	if player:
		$NavigationAgent3D.target_position = player.global_transform.origin


# ---------------- KILL + LEADERBOARD ----------------
func kill_player():
	if killcast_shape and not ending_playing:
		killcast_shape.enabled = true
		$killcast.look_at(player.global_transform.origin)

	if killcast_shape.is_colliding():
		var hit = $killcast/killcast.get_collider()
		if hit.name == "player" and not killed and not ending_playing:
			killed = true
			ending_playing = true

			chase_music.stop()
			spotlight.visible = true
			$jumpscare_cam.current = true
			$monster/AnimationPlayer.play("jumpscare")
			$monster/AnimationPlayer.speed_scale = 2
			player.process_mode = Node.PROCESS_MODE_DISABLED
			$eye_glow.visible = false
			jumpscare.play()

			# Wait for jumpscare
			await get_tree().create_timer(7.56, false).timeout
			
			$monster/AnimationPlayer.stop()
			
			# ✅ Save orbs collected to leaderboard
			if hud:
				save_orb_score(load_player_name(), hud.orbsCollected)


			# Show leaderboard
			if ui:
				ui.show_leaderboard()
				ui.visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func save_orb_score(player_name: String, orbs: int):
	var path = "user://leaderboard.json"
	var data: Array = []

	# Load existing leaderboard
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if typeof(parsed) == TYPE_ARRAY:
				data = parsed
			f.close()

	var found := false
	for entry in data:
		if entry.has("name") and entry["name"] == player_name:
			# Update the score if the new score is higher
			entry["orbs"] = max(entry["orbs"], orbs)
			found = true
			break

	# If not found, append new record
	if not found:
		data.append({ "name": player_name, "orbs": orbs })

	# Save updated leaderboard
	var f2 = FileAccess.open(path, FileAccess.WRITE)
	if f2:
		f2.store_string(JSON.stringify(data))
		f2.close()


# ---------------- PLAYER NAME HELPER ----------------
func load_player_name() -> String:
	var path = "user://player_data.json"
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			f.close()
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("name"):
				return str(parsed["name"])
	return "Player"
