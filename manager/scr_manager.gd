# SCENE: Manager
#
# DESC.: Your traditinal Game Manager, used to managing things that are global scope
#
# NOTABLE FUNCTIONS AND VARIABLES:
# - game_version :String
# - change_scene(scene_path :String, anm_vel :float, anm_name :String = ("fade"/"cut"))
# - pause_game()
# - open_settings_menu()
# - close_settings_menu()
# - settings :Dictionary
#
# OBS.: 
# - The "README.txt" file needs to be located besides the game's executable file
# (or the godot's executable) for it to open.
# - The save file will also be located besides the game's executable, to change
# this, replace 'settings_file_path' value to just "user://Settings.ini".
# - It's recommended to put all your global variables in the script, since it's a 
# AutoLoad and can be accessed from anywhere.

extends Control

var game_version :String
func _ready():
	load_settings()
	apply_settings()
	
	var version = VersionDescriber.new()
	game_version = version.game_version()
	
	OS.set_window_title(ProjectSettings.get("application/config/name") + " - " + game_version)

func _process(delta):
	if Input.is_action_just_pressed("pause_game"): 
		if not get_tree().current_scene.is_in_group("menu"):
			pause_game()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		settings.fullscr = !settings.fullscr
		apply_settings()
	if Input.is_action_just_pressed("debug") and OS.has_feature("debug"):
		$Debug.visible = !$Debug.visible
	
	if $Debug.visible:
		$Debug/txtInfo.text = game_version + "\n"
		$Debug/txtInfo.text += "FPS:" + str(Engine.get_frames_per_second()) + "\n"
		$Debug/txtInfo.text += "RAM:" + str(OS.get_static_memory_usage() / 1000000.0) + " MiB\n"
		$Debug/txtInfo.text += "VRAM:" + str(VisualServer.get_render_info(VisualServer.INFO_VIDEO_MEM_USED) / 1000000.0) + " MiB\n"

func change_scene(scene_path :String, anm_vel :float = 1, anm_name :String = "fade"):
	$Transitions/anm.play(anm_name, -1, anm_vel, false)
	yield($Transitions/anm, "animation_finished")
	
	get_tree().change_scene(scene_path)
	
	$Transitions/anm.play(anm_name, -1, -anm_vel, true)

var game_paused :bool = false
signal game_paused
signal game_resumed
func pause_game():
	game_paused = !game_paused
	
	$PauseMenu.visible = game_paused
	get_tree().paused = game_paused
	if OS.has_feature("web") or OS.has_feature("mobile"): $PauseMenu/centercon/vbcon/btnExitOS.visible = false
	
	if $SettingsMenu.visible:
		save_settings()
		close_settings_menu()
	
	if game_paused:
		emit_signal("game_paused")
		VisualServer.set_shader_time_scale(0)
		$sfxOpen.play()
	else:
		emit_signal("game_resumed")
		VisualServer.set_shader_time_scale(1)
func _on_btnResume_pressed(): pause_game()
func _on_btnSettings_pressed(): open_settings_menu()
func _on_btnReadme_pressed(): OS.shell_open(OS.get_executable_path().get_base_dir().plus_file("README.txt"))
func _on_btnMoreGames_pressed(): OS.shell_open("https://itch.io") # INSERT LINK HERE
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
var settings_file_path :String = OS.get_executable_path().get_base_dir().plus_file("Settings.ini")
const settings_file_ini_section :String = "Settings"
func load_settings():
	var dir = Directory.new()
	if dir.file_exists(settings_file_path):
		var settings_file = ConfigFile.new()
		settings_file.load(settings_file_path)
		
		for setting in settings_file.get_section_keys(settings_file_ini_section):
			settings[setting] = settings_file.get_value(settings_file_ini_section, setting)
func save_settings():
	var settings_file = ConfigFile.new()
	
	for setting in settings.keys():
		settings_file.set_value(settings_file_ini_section, setting, settings.get(setting))
	
	settings_file.save(settings_file_path)

func open_settings_menu():
	$SettingsMenu.visible = true
	_setup_settings_menu()
func close_settings_menu():
	$SettingsMenu.visible = false
func _setup_settings_menu():
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
