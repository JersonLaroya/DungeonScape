extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/AnimationPlayer.play("fade")
	await get_tree().create_timer(8.0, false).timeout
	get_tree().change_scene_to_file("res://ui/home_page.tscn")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file("res://ui/home_page.tscn")
