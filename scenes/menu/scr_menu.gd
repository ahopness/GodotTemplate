# SCENE: Main Menu
#
# DESC.: Your traditinal Main Menu, made to be as flexible as
# possible for you to personalize it to your liking, toggle
# any node's visibility if you don't want to it be shown, change
# animations, textures and texts. Obs: beware, some buttons here
# link to functions that are in the Manager AutoLaod.

extends Control

func _ready():
	if OS.has_feature("web") or OS.has_feature("mobile"): $actions/btnExit.visible = false
	
	$txtVersion.text = Manager.game_version

func _on_btnStart_pressed():
	$anm.play("anmStart")

func _on_btnPlay_pressed():
#	Manager.change_scene() insert scene at here
	pass
func _on_btnSettings_pressed(): Manager.open_settings_menu()
func _on_btnCredits_pressed(): $credits.visible = true
func _on_btnReadme_pressed(): Manager._on_btnReadme_pressed()
func _on_btnMore_pressed(): Manager._on_btnMoreGames_pressed()
func _on_btnExit_pressed(): get_tree().quit()

func _on_btnCreditsBack_pressed(): $credits.visible = false
