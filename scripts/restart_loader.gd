extends Node

var target_scene_path: String

func _ready():
	_load_scene_async()


func _load_scene_async():
	var err = ResourceLoader.load_threaded_request(target_scene_path)
	if err != OK:
		print("Failed to request load: ", err)
		return

	while ResourceLoader.load_threaded_get_status(target_scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	var status = ResourceLoader.load_threaded_get_status(target_scene_path)

	if status == ResourceLoader.THREAD_LOAD_FAILED:
		print("Scene failed to load")
		return

	var packed_scene = ResourceLoader.load_threaded_get(target_scene_path)
	get_tree().change_scene_to_packed(packed_scene)
	queue_free()
