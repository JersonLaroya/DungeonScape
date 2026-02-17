extends Area3D

var collected := false

@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	if anim_player:
		anim_player.play("orb")  # replace with your actual animation
	else:
		print("Error: AnimationPlayer not found!")


func _on_body_entered(body: Node3D) -> void:
	if collected:
		return
	
	if body.name != "player": # make sure it matches your actual player node name or use group
		return
	
	collected = true
	$orb_sound.play()
	$MeshInstance3D.queue_free()
	set_deferred("monitoring", false)

	# Update HUD counter
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.add_orb()

func _on_orb_sound_finished() -> void:
	queue_free()
