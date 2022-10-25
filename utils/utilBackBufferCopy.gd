extends BackBufferCopy

export var auto_update_visibility :bool = true
func _ready():
	get_tree().root.connect("size_changed", self, "update_size")
	
	if auto_update_visibility:
		Manager.connect("settings_changed", self, "update_visibility")
		update_visibility()

func update_size():
	var window_size :Vector2 = get_viewport_rect().size / 2
	position = window_size
	scale = window_size / 100
func update_visibility():
	visible = Manager.settings.pp
