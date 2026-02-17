extends Control

func play_interact() -> void:
	$interact.play()

func play_hover():
	$hover.play()
	
func start_game():
	play_interact()
	$main.visible = false
	$mode.visible = true

func skip1():
	play_interact()
	await get_tree().create_timer(0.5, true).timeout
	get_tree().change_scene_to_file("res://materials/levels/survival.tscn")
	
func skip2():
	play_interact()
	await get_tree().create_timer(0.5, true).timeout
	get_tree().change_scene_to_file("res://materials/levels/endless.tscn")

func play_mode1():
	play_interact()
	$main.visible = false
	$survival_story.visible = true
	$music.stop()
	$survival_story/AnimationPlayer.play("storyline")
	$survival_story/AudioStreamPlayer.play()
	await get_tree().create_timer(133.93, true).timeout
	get_tree().change_scene_to_file("res://materials/levels/survival.tscn")

func play_mode2():
	play_interact()
	$main.visible = false
	$endless_story.visible = true
	$music.stop()
	$endless_story/AnimationPlayer.play("storyline")
	$endless_story/AudioStreamPlayer.play()
	await get_tree().create_timer(133.93, true).timeout
	get_tree().change_scene_to_file("res://materials/levels/endless.tscn")

func open_settings():
	play_interact()
	$main.visible = false
	$settings.visible = true

func open_controls():
	play_interact()
	$main.visible = false
	$controls.visible = true

func open_credits():
	play_interact()
	$main.visible = false
	$credits.visible = true
	$credits/AnimationPlayer.play("credits")

func confirm_yes():
	play_interact()
	await get_tree().create_timer(0.5, true).timeout
	get_tree().quit()
	
func confirm_no():
	play_interact()
	$settings.visible = false
	$controls.visible = false
	$credits.visible = false
	$credits/AnimationPlayer.stop()
	$are_you_sure.visible = false
	$main.visible = true

func quit_game():
	play_interact()
	$main.visible = false
	$are_you_sure.visible = true
