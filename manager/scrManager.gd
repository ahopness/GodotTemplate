extends Control

var game_version :String
func _ready():
	OS.set_window_title(ProjectSettings.get("application/config/name"))
	
	load_settings()
	apply_settings()
	
	var version = VersionDescriber.new()
	game_version = version.game_version() + "\n"

func _process(delta):
	if Input.is_action_just_pressed("pause_game"): pause_game()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		settings.fullscr = !settings.fullscr
		apply_settings()
	if Input.is_action_just_pressed("debug") and OS.has_feature("debug"):
		$Debug.visible = !$Debug.visible
	
	if $Debug.visible:
		$Debug/txtInfo.text = game_version
		$Debug/txtInfo.text += "FPS:" + str(Engine.get_frames_per_second()) + "\n"
		$Debug/txtInfo.text += "RAM:" + str(OS.get_static_memory_usage() / 1000000.0) + " MiB\n"
		$Debug/txtInfo.text += "VRAM:" + str(VisualServer.get_render_info(VisualServer.INFO_VIDEO_MEM_USED) / 1000000.0) + " MiB\n"

func change_scene(scene :String, anm_vel :float = 1):
	$Transitions/anm.play("anmFade", -1, anm_vel, false)
	yield($Transitions/anm, "animation_finished")
	
	get_tree().change_scene(scene)
	
	$Transitions/anm.play("anmFade", -1, -anm_vel, true)

var game_paused :bool = false
func pause_game():
	game_paused = !game_paused
	
	$PauseMenu.visible = game_paused
	get_tree().paused = game_paused
	if OS.has_feature("web") or OS.has_feature("mobile"): $PauseMenu/centercon/vbcon/btnExitOS.visible = false
	
	if $SettingsMenu.visible:
		save_settings()
		close_settings_menu()
func _on_btnResume_pressed(): pause_game()
func _on_btnSettings_pressed(): open_settings_menu()
func _on_btnExitMenu_pressed():
	pause_game()
	change_scene("res://scenes/menu.tscn")
func _on_btnExitOS_pressed(): get_tree().quit()

signal settings_changed
var settings :Dictionary = {
	"vsync": true,
	"fullscr": true,
	"pp": true,
	"mus": 1.0,
	"sfx": 1.0}
func apply_settings():
	OS.vsync_enabled = settings.vsync
	OS.window_fullscreen = settings.fullscr
	
	$PostProcessing.visible = settings.pp
	
	AudioServer.set_bus_volume_db(1, linear2db(settings.mus))
	AudioServer.set_bus_volume_db(2, linear2db(settings.sfx))
	
	emit_signal("settings_changed")
var settings_file_path :String = "user://settings.data"
func load_settings():
	var dir = Directory.new()
	if dir.file_exists(settings_file_path):
		var settings_file = File.new()
		settings_file.open(settings_file_path, File.READ)
		settings = settings_file.get_var()
		settings_file.close()
func save_settings():
	var settings_file = File.new()
	settings_file.open(settings_file_path, File.WRITE)
	settings_file.store_var(settings)
	settings_file.close()

func open_settings_menu():
	$SettingsMenu.visible = true
	setup_settings_menu()
func close_settings_menu():
	$SettingsMenu.visible = false
	setup_settings_menu()
func setup_settings_menu():
	$SettingsMenu/centercon/vbcon/vsync/chkbtnVsync.pressed = settings.vsync
	$SettingsMenu/centercon/vbcon/fullscr/chkbtnFullscr.pressed = settings.fullscr
	$SettingsMenu/centercon/vbcon/pp/chkbtnPP.pressed = settings.pp
	
	$SettingsMenu/centercon/vbcon/mus/hsldMus.value = settings.mus
	$SettingsMenu/centercon/vbcon/sfx/hsldSfx.value = settings.sfx

func _on_chkbtnVsync_toggled(button_pressed):
	settings.vsync = button_pressed
func _on_chkbtnFullscr_toggled(button_pressed):
	settings.fullscr = button_pressed
func _on_chkbtnPP_toggled(button_pressed):
	settings.pp = button_pressed
func _on_hsldMus_value_changed(value):
	settings.mus = value
func _on_hsldSfx_value_changed(value):
	settings.sfx = value
