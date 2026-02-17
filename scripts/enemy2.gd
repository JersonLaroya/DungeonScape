extends CharacterBody3D

@onready var player = get_tree().current_scene.get_node("player")
@onready var chasecasts = [
	$chasecast, $chasecast2, $chasecast3, $chasecast4, $chasecast5
]

# Lights Container
@onready var dungeon_lights = $"../test/dungeon_lights"

# Audio
@onready var chase_music: AudioStreamPlayer = $chase_music
@onready var chase_music_final: AudioStreamPlayer = $chase_music_final
@onready var monster_growl: AudioStreamPlayer3D = $monster_growl
@onready var monster_growl2: AudioStreamPlayer3D = $monster_growl2
@onready var monster_scream: AudioStreamPlayer3D = $scream
@onready var jumpscare: AudioStreamPlayer = $jumpscare
@onready var spotlight = $monster/SpotLight3D

var scream_played: bool = false
var music_delay_started: bool = false
var got_key: bool = false

var final_chase_started: bool = false
var ending_playing: bool = false

# Flicker settings
var lights_on: bool = true
var flicker_timer: float = 0.0
var flicker_interval: float = 0.1
var flicker_distance: float = 20.0
var rng := RandomNumberGenerator.new()

# State
var chasing: bool = false
var killed: bool = false
@export var normal_speed := 5
@export var chase_speed := 10.0

var chase_timer: float = 0.0
var max_chase_time: float = 15.0

# Monster growl control
var growls: Array = []
var growl_timer: float = 0.0
var growl_delay: float = 2.0  # seconds before next growl

func _ready():
	# Add growls to array
	growls = [monster_growl, monster_growl2]
	# Play first random growl
	play_random_growl()

func fade_out_music():
	var tween = get_tree().create_tween()
	tween.tween_property(chase_music, "volume_db", -40.0, 1.5) # fade to almost silent in 1.5 seconds
	tween.finished.connect(func():
		chase_music.stop()
		chase_music.volume_db = 0.0 # reset volume for next play
	)


func play_random_growl():
	# Stop all growls first
	for g in growls:
		if g.playing:
			g.stop()

	# Pick a random growl
	var index = rng.randi_range(0, growls.size() - 1)
	var selected_growl = growls[index]
	selected_growl.play()

	# Reset timer for next growl
	growl_timer = 0.0
	# Randomize delay a bit
	growl_delay = rng.randf_range(2.0, 5.0)


# ---------------- LIGHT HELPERS ----------------
func get_all_lights(root: Node) -> Array:
	var output: Array = []
	for child in root.get_children():
		if child is Light3D:
			output.append(child)
		if child.get_child_count() > 0:
			output += get_all_lights(child)
	return output

func get_all_spheres(root: Node) -> Array:
	var output: Array = []
	for child in root.get_children():
		if child is MeshInstance3D and "Sphere" in child.name:
			output.append(child)
		if child.get_child_count() > 0:
			output += get_all_spheres(child)
	return output


func toggle_lights():
	lights_on = !lights_on
	for light in get_all_lights(dungeon_lights):
		if player.global_position.distance_to(light.global_position) <= flicker_distance:
			light.visible = lights_on
	for sphere in get_all_spheres(dungeon_lights):
		if player.global_position.distance_to(sphere.global_position) <= flicker_distance:
			sphere.visible = lights_on

func set_lights_on():
	for light in get_all_lights(dungeon_lights):
		light.visible = true
	for sphere in get_all_spheres(dungeon_lights):
		sphere.visible = true
	lights_on = true

# ---------------- FINAL CHASE TRIGGER ----------------
func start_final_chase():
	if killed or final_chase_started:
		return

	final_chase_started = true
	
	chase_speed = 30
	
	print("normal speed:", normal_speed)
	print("chasing speed:", chase_speed)

	# stop idle growls and normal chase music
	for g in growls:
		if g.playing:
			g.stop()
	fade_out_music()

	# Reset chase flags and force chase
	scream_played = false
	music_delay_started = false
	chasing = true
	chase_timer = 0.0

	# Play scream
	monster_scream.play()

	# small pause then start final music
	await get_tree().create_timer(0.25).timeout
	if not chase_music_final.playing:
		chase_music_final.volume_db = 0.0
		chase_music_final.play()
		var t = get_tree().create_tween()
		t.tween_property(chase_music_final, "volume_db", 0.0, 0.5)

# ---------------- MAIN LOGIC ----------------
func _process(delta: float) -> void:
	if killed or ending_playing:
		for g in growls:
			if g.playing:
				g.stop()
		if chase_music.playing:
			fade_out_music()
		return

	# Handle growl looping with delay
	growl_timer += delta
	var any_playing = false
	for g in growls:
		if g.playing:
			any_playing = true
			break

	if not any_playing and growl_timer >= growl_delay:
		play_random_growl()

	# Check raycasts to trigger chase
	for ray in chasecasts:
		check_chase(ray)

	# Always follow player's location
	update_target_location()

	if chasing:
		if not final_chase_started:
			if chase_timer < max_chase_time:
				chase_timer += delta
			else:
				# Reset chase state
				chasing = false
				chase_timer = 0.0
				if $killcast/killcast.enabled:
					$killcast/killcast.enabled = false
				set_lights_on()
				if chase_music.playing:
					chase_music.stop()

	# Handle lights + audio states
	if chasing:
		handle_chase_effects(delta)
	else:
		handle_idle_effects()


func handle_idle_effects():
	set_lights_on()
	if chase_music.playing:
		fade_out_music()

	scream_played = false
	music_delay_started = false


func handle_chase_effects(delta: float):
	# Scream first
	if not scream_played:
		monster_scream.play()
		scream_played = true
		return

	# After screaming, wait 1 second before starting the chase music
	if scream_played and not music_delay_started:
		music_delay_started = true
		await get_tree().create_timer(1.0).timeout

	# Start chase music (but only after delay)
	if not chase_music.playing:
		chase_music.play()

	# Lights flickering
	flicker_timer += delta
	if flicker_timer >= flicker_interval:
		toggle_lights()
		flicker_timer = 0.0
		flicker_interval = rng.randf_range(0.05, 0.2)


func check_chase(ray: RayCast3D):
	if ray.is_colliding():
		var hit = ray.get_collider()
		if hit.name == "player":
			chasing = true


func _physics_process(_delta: float) -> void:
	if killed or ending_playing:
		return

	var current_location = global_transform.origin
	var next_location = $NavigationAgent3D.get_next_path_position()
	var target_speed = chase_speed if chasing else normal_speed

	var new_velocity = (next_location - current_location).normalized() * target_speed
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()

	# ROTATE TO FACE MOVEMENT DIRECTION
	if velocity.length() > 0.1:
		var target_angle = atan2(-velocity.x, -velocity.z)
		var current_angle = deg_to_rad(global_rotation_degrees.y)
		var new_angle = lerp_angle(current_angle, target_angle, 0.2)
		global_rotation_degrees.y = rad_to_deg(new_angle)

	# Kill only while chasing
	if chasing:
		kill_player()
		

	print("normal speed:", normal_speed)
	print("chasing speed:", chase_speed)



func update_target_location():
	if player:
		$NavigationAgent3D.target_position = player.global_transform.origin


func kill_player():
	if !$killcast/killcast.enabled:
		$killcast/killcast.enabled = true
	$killcast.look_at(player.global_transform.origin)
	if $killcast/killcast.is_colliding():
		var hit = $killcast/killcast.get_collider()
		if hit.name == "player" and !killed:
			killed = true
			chase_music.stop()
			chase_music_final.stop()
			spotlight.visible = true
			$jumpscare_cam.current = true
			$monster/AnimationPlayer.play("jumpscare")
			$monster/AnimationPlayer.speed_scale = 2
			player.process_mode = Node.PROCESS_MODE_DISABLED
			$eye_glow.visible = false
			jumpscare.play()
			await get_tree().create_timer(7.56, false).timeout
			get_tree().reload_current_scene()
