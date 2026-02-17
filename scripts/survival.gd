extends Node3D

func _ready() -> void:
	$survival_guide.visible = true
	await get_tree().create_timer(5.0).timeout
	$survival_guide.visible = false
