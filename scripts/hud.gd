extends CanvasLayer

var orbsCollected := 0
var addSpeed := 0
@onready var ui = get_tree().current_scene.get_node("player/player_ui/message_ui")

@onready var spawn_points = [
	get_parent().get_node("spawn_point1"),
	get_parent().get_node("spawn_point2"),
	get_parent().get_node("spawn_point3"),
	get_parent().get_node("spawn_point4"),
	get_parent().get_node("spawn_point5"),
	get_parent().get_node("spawn_point6"),
	get_parent().get_node("spawn_point7"),
	get_parent().get_node("spawn_point8"),
	get_parent().get_node("spawn_point9"),
	get_parent().get_node("spawn_point10"),
]

func _ready() -> void:
	_update_label()

func _update_label() -> void:
	$orb_count.text = "Orbs: " + str(orbsCollected) + " / 80"
	

func add_orb() -> void:
	orbsCollected += 1
	addSpeed += 1
	_update_label()
	
	var enemy = get_tree().current_scene.get_node("enemy") # adjust path
	if enemy:
		if addSpeed == 20:
			enemy.normal_speed += 1
			enemy.chase_speed += 1
			addSpeed = 0

	if orbsCollected == 80:
		spawn_key()

func spawn_key():
	var random_point = spawn_points[randi() % spawn_points.size()]
	var key = get_parent().get_node("key")
	if not key:
		print("Error: Key node not found!")
		return
	key.global_transform.origin = random_point.global_transform.origin
	key.visible = true
	if ui:
		ui.visible = true
		var anim_player = ui.get_node("AnimationPlayer")
		if anim_player:
			anim_player.play("key_appeared")
