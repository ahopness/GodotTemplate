extends Control

@export var active :bool = true

enum type {TOP_LEFT, CENTER}
@export_enum("Top Left", "Center") var gradient_type :int = type.TOP_LEFT

func _ready():
	modulate.a = 0

var _prev_focus_owner :Object
var _tween
func _process(delta):
	if active:
		match gradient_type:
			type.TOP_LEFT:
				$texGradientTopLeft.visible = true
				$texGradientCenter.visible = false
			type.CENTER:
				$texGradientTopLeft.visible = false
				$texGradientCenter.visible = true
		
		if not get_viewport().gui_get_focus_owner() == _prev_focus_owner:
			if _tween: _tween.kill()
			_tween = create_tween()
			modulate.a = 0
			_tween.tween_property(self, "modulate:a", 1, .7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		_prev_focus_owner = get_viewport().gui_get_focus_owner()
		
		if not get_viewport().gui_get_focus_owner() == null:
			match gradient_type:
				type.TOP_LEFT:
					self.global_position = get_viewport().gui_get_focus_owner().global_position + get_viewport().gui_get_focus_owner().pivot_offset
				type.CENTER:
					self.global_position = get_viewport().gui_get_focus_owner().global_position + get_viewport().gui_get_focus_owner().size / 2
		else:
			modulate.a = 0
	else:
		modulate.a = 0
