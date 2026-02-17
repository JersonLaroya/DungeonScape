extends Node3D

@export var orb_scene: PackedScene
@export var navigation_region: NavigationRegion3D
@export var orb_count: int = 20
@export var spawn_height_offset: float = 0.3
@export var max_attempts_per_orb: int = 10

func _ready():
	spawn_orbs()

func spawn_orbs():
	if not orb_scene:
		push_error("orb_scene not assigned.")
		return
	if not navigation_region:
		push_error("navigation_region not assigned.")
		return

	var nav_map = navigation_region.get_navigation_map()
	if nav_map == RID():
		push_error("navigation_region has no navigation map (bake the NavigationMesh first).")
		return

	# --- Explicitly type the nav_aabb variable ---
	if not navigation_region.has_method("get_transformed_aabb"):
		push_error("navigation_region does not have get_transformed_aabb(). If using an older/odd build, assign a floor node instead.")
		return

	var nav_aabb: AABB = navigation_region.get_transformed_aabb()  # explicit type avoids inference error

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var spawned := 0
	var tries := 0

	while spawned < orb_count and tries < orb_count * max_attempts_per_orb:
		tries += 1

		var random_point := Vector3(
			rng.randf_range(nav_aabb.position.x, nav_aabb.position.x + nav_aabb.size.x),
			nav_aabb.position.y,
			rng.randf_range(nav_aabb.position.z, nav_aabb.position.z + nav_aabb.size.z)
		)

		var closest_point := NavigationServer3D.map_get_closest_point(nav_map, random_point)
		if closest_point == Vector3():
			continue

		closest_point.y += spawn_height_offset

		# avoid overlaps
		var too_close := false
		for child in get_children():
			if child is Node3D and child.name.begins_with("Orb"):
				if child.global_position.distance_to(closest_point) < 1.0:
					too_close = true
					break
		if too_close:
			continue

		var orb := orb_scene.instantiate()
		orb.name = "Orb_%d" % spawned
		orb.global_position = closest_point
		add_child(orb)

		print("Spawned orb at:", closest_point)
		spawned += 1

	if spawned < orb_count:
		push_warning("Spawned only %d/%d orbs (limited valid navmesh points)." % [spawned, orb_count])
