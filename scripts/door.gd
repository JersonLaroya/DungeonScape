extends Node3D

@onready var ui = get_tree().current_scene.get_node("player/player_ui/ending")

var have_key = false;

func key():
	have_key = true

func _on_body_entered(_body: Node3D) -> void:
	if have_key:
		$Camera3D.current = true
		$ending_sound.play()
		$AnimationPlayer.play("ending")
		
		 # Tell the enemy to stop
		var enemy = get_tree().current_scene.get_node("enemy") # adjust path
		if enemy:
			enemy.ending_playing = true
			if enemy.chase_music_final and enemy.chase_music_final.playing:
				enemy.chase_music_final.stop()
				
		await get_tree().create_timer(7, true).timeout
		if ui:
			ui.visible = true
			var anim_player = ui.get_node("AnimationPlayer")
			if anim_player:
				anim_player.play("game_ending")
				
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
