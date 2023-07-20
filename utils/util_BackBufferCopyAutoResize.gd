extends BackBufferCopy

func _ready():
	get_tree().root.size_changed.connect(update_size)

func update_size():
	var window_size :Vector2 = get_viewport_rect().size / 2
	position = window_size
	scale = window_size / 100
