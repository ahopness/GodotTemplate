extends Button

func _ready():
	mouse_entered.connect(grab_focus)
