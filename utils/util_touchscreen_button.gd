# UTILITY SCRIPT: TrouchScreenButton auto-resizer
# 
# DESC.: Attatch this script to a TrouchScreenButton to make it resize
# to the screen's resolution automatically. Useful for making
# fullscreen buttons for the player to skip cutscenes. Great for both 
# mobile and PC due to 'input_devices/pointing/emulate_touch_from_mouse'.

extends TouchScreenButton

func _ready():
	get_tree().root.connect("size_changed", self, "update_size")
	update_size()

func update_size():
	var window_size :Vector2 = get_viewport_rect().size / 2
	if shape is RectangleShape2D:
		shape.extents = window_size
