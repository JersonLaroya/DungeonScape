extends Node3D

@export var orb_scene: PackedScene  # drag your orb.tscn here in the inspector
@export var y_offset := 1.0  # height above marker

func _ready() -> void:
	print("hehe")
	spawn_orbs_at_markers()

func spawn_orbs_at_markers() -> void:
	if not orb_scene:
		push_error("Orb scene not assigned!")
		return

	for marker in get_children():
		if marker is Marker3D:
			# Print debug info
			print("Spawning orb at marker: ", marker.name, " position: ", marker.global_position)

			# Spawn orb
			var orb = orb_scene.instantiate()
			orb.global_position = marker.global_position + Vector3(0, y_offset, 0)
			orb.spawn_point = marker
			get_tree().current_scene.add_child(orb)
