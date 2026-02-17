extends Node3D

func _ready() -> void:
	$endless_guide.visible = true
	await get_tree().create_timer(5.0).timeout
	$endless_guide.visible = false
