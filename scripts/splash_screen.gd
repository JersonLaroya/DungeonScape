extends Control

@export var in_time: float = 0.5
@export var fade_in_time: float = 1.5
@export var pause_time: float = 1.5
@export var fade_out_time: float = 1.5
@export var out_time: float = 0.5
@export var splash_screen: TextureRect

func _ready() -> void:
	if splash_screen == null:
		push_error("Splash screen node is NOT assigned or NOT found!")
		return

	fade()

func fade() -> void:
	# Start fully transparent
	splash_screen.modulate.a = 0.0

	var tween = create_tween()

	# Wait before appearing
	tween.tween_interval(in_time)

	# Fade in to visible
	tween.tween_property(splash_screen, "modulate:a", 1.0, fade_in_time)

	# Stay on screen
	tween.tween_interval(pause_time)

	# Fade OUT to invisible (FIXED)
	tween.tween_property(splash_screen, "modulate:a", 0.0, fade_out_time)

	# Wait before switching
	tween.tween_interval(out_time)

	await tween.finished

	get_tree().change_scene_to_file("res://scenery/warning.tscn")
