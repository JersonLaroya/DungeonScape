extends CharacterBody3D

const SPEED = 15.0
const JUMP_VELOCITY = 4.5

@onready var footstep_player: AudioStreamPlayer = $footstep
@onready var footstep_timer := Timer.new()

func _ready() -> void:
	add_child(footstep_timer)
	footstep_timer.wait_time = 0.4
	footstep_timer.one_shot = true
	randomize()

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movement input
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		play_footstep() # play sound when moving
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		stop_footstep() # stop when not moving

	move_and_slide()


func play_footstep() -> void:
	# only play if on floor and not too soon
	if not is_on_floor():
		return
	if not footstep_timer.is_stopped():
		return

	# play sound once per timer
	footstep_player.play()
	footstep_timer.start()


func stop_footstep() -> void:
	# stop the sound if playing
	if footstep_player.playing:
		footstep_player.stop()
