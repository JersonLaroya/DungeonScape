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
	
	if body.name != "player":
		return
	
	collected = true
	$orb_sound.play()
	
	# Hide orb safely
	call_deferred("_hide_orb")

	# Update HUD counter
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.add_orb(20)

func _hide_orb() -> void:
	$MeshInstance3D.visible = false
	$Cube.visible = false
	$Cube2.visible = false
	$Sphere.visible = false
	$OmniLight3D.visible = false
	$CollisionShape3D.disabled = true
	set_deferred("monitoring", false)
	
	# Wait 3 seconds
	await get_tree().create_timer(20.0).timeout
	
	# Show orb again
	$MeshInstance3D.visible = true
	$Cube.visible = true
	$Cube2.visible = true
	$Sphere.visible = true
	$OmniLight3D.visible = true
	$CollisionShape3D.disabled = false
	collected = false
	set_deferred("monitoring", true)
