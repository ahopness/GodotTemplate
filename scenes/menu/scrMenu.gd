extends Control

func _ready():
	if OS.has_feature("web") or OS.has_feature("mobile"): $actions/btnExit.visible = false
	
	var version = VersionDescriber.new()
	$txtVersion.text = version.game_version()

var can_interact :bool = false
func _on_anm_animation_finished(anm):
	can_interact = true

func _on_btnStart_pressed():
	if can_interact: 
		$sfxStart.play()
		$anm.play("anmStart")

func _on_btnPlay_pressed():
#	Manager.change_place("")
	print("insert scene at here (scrMenu.gd:19)")
func _on_btnSettings_pressed():
	Manager.open_settings_menu()
func _on_btnCredits_pressed():
	$credits.visible = true
func _on_btnMore_pressed():
#	OS.shell_open("https://linktr.ee/ahopness")
	print("insert link at here (scrMenu.gd:26)")
func _on_btnExit_pressed():
	get_tree().quit()

func _on_btnCreditsBack_pressed():
	$credits.visible = false
