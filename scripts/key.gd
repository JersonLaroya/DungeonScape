extends Area3D

var collected := false

var msg

func _ready():
	msg = get_tree().current_scene.get_node("player/player_ui/go_to_exit_message")
	if not msg:
		print("Error: Go-to-exit message node not found!")

func _on_body_entered(body: Node3D) -> void:
	if not visible or collected or body.name != "player":
		return

	collected = true
	var key_holds = get_tree().get_first_node_in_group("key_hold")
	if key_holds:
		key_holds.start_final_chase()
	if msg:
		$key_picked.play()
		msg.visible = true
		var anim_player = msg.get_node("AnimationPlayer")
		if anim_player:
			anim_player.play("message")

	var got_key = get_tree().get_first_node_in_group("door")
	if got_key:
		got_key.key()
	else:
		print("Error: No door in 'door' group!")

	# Queue children for deletion only if they exist
	if $Node3D:
		$Node3D.queue_free()
	if $OmniLight3D:
		$OmniLight3D.queue_free()
	set_deferred("monitoring", false)
