extends CanvasLayer

var orbsCollected := 0

func _ready() -> void:
	_update_label()

func _update_label() -> void:
	$orb_count.text = "Orbs: " + str(orbsCollected)

func add_orb(add) -> void:
	orbsCollected += add
	_update_label()
