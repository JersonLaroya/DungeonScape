extends Control

@onready var credits_label = $CreditsLabel
@onready var music = $CreditsMusic

# Speed in pixels per second
@export var scroll_speed := 50.0

# Flag to pause/resume
var paused := false

func _ready():
	# Example credit text
	credits_label.bbcode_enabled = true
	credits_label.text = """
[b]Game Design & Development[/b]
Jerson Laroya

[b]Art & Animation[/b]
Jerson Laroya

[b]Sound & Music[/b]
Walking sound - Mixkit (free, no attribution)
Monster Growls - FreeSound (TheOnlyPKMNmaster)

[b]Special Thanks[/b]
Godot Engine
Testers and Friends
"""
	
	# Position the label below the screen to start scrolling
	credits_label.rect_position.y = size.y
	
	# Play music if available
	if music.stream:
		music.play()

func _process(delta):
	if paused:
		return

	# Scroll upwards
	credits_label.rect_position.y -= scroll_speed * delta

	# End credits when fully scrolled
	if credits_label.rect_position.y + credits_label.rect_size.y < 0:
		end_credits()

func pause_credits():
	paused = true
	if music.playing:
		music.stop()

func resume_credits():
	paused = false
	if music.stream:
		music.play()

func skip_credits():
	end_credits()

func end_credits():
	# You can change scene or show main menu here
	if music.playing:
		music.stop()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
