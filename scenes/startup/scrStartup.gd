extends CenterContainer

func _on_btnProceed_pressed():
	$sfxClick.play()
	Manager.change_scene("res://scenes/menu.tscn", .5)
