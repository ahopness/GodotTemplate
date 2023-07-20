extends Control

@export var globals :Dictionary = { } 
@export var info :Dictionary = { } # globals to save to disc. ex: player health, inventory, etc.
@export var settings :Dictionary = {
	"lang": "en_US",
	"vsync": true,
	"fullscr": false,
	"low_gfx": false,
	"sfx": 1.0,
	"mus": 1.0}

var game_version :String
func _ready():
	var version = VersionDescriber.new()
	game_version = version.get_game_version()
	
	DisplayServer.window_set_title(ProjectSettings.get("application/config/name") + game_version) 
	
	load_settings()
	apply_settings()
	
	$Debug/txtInfo.visible = OS.has_feature("debug")

func _process(delta):
	if Input.is_action_just_pressed("pause_game"): pause_game()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		settings.fullscr = !settings.fullscr
		apply_settings()
		save_settings()
	if Input.is_action_just_pressed("debug") and OS.has_feature("debug"):
		$Debug/txtInfo.visible = !$Debug/txtInfo.visible
	
	if $Debug.visible:
		$Debug/txtInfo.text = game_version + "\n"
		$Debug/txtInfo.text += "FPS:" + str(Engine.get_frames_per_second()) + "\n"
		$Debug/txtInfo.text += "RAM:" + str(OS.get_static_memory_usage() / 1000000.0) + " MiB\n"

func change_scene(scene :String, anm_vel :float = 1, anm_name :String = "fade"):
	$Transitions/anm.play(anm_name, -1, anm_vel, false)
	await $Transitions/anm.animation_finished
	
	get_tree().change_scene_to_file(scene)
	
	$Transitions/anm.play(anm_name, -1, -anm_vel, true)

signal pause_menu_openned
signal pause_menu_closed
var game_paused :bool = false
func pause_game():
	if not get_tree().current_scene.is_in_group("menu"):
		game_paused = !game_paused
		
		if game_paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
			$PauseMenu/vbconControls.visible = true
			$PauseMenu/vbconConfirmation.visible = false
			
			var tween = create_tween()
			tween.set_parallel(true)
			
			$PauseMenu/bg.modulate.a = 0
			tween.tween_property($PauseMenu/bg, "modulate:a", 1, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			
			$PauseMenu/vbconControls/vsep.remove_theme_constant_override("separation")
			$PauseMenu/vbconControls/vsep.add_theme_constant_override("separation", 30)
			tween.tween_property($PauseMenu/vbconControls/vsep, "theme_override_constants/separation", 50, .5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			
			$PauseMenu/oSelectionHighlight.active = true
			await get_tree().process_frame # <- Don't touch, no idea why but it only works this way
			await get_tree().process_frame
			$PauseMenu/vbconControls/vbconActions/btnResume.grab_focus()
			
			emit_signal("pause_menu_openned")
		else:
			$PauseMenu/oSelectionHighlight.active = false
			
			emit_signal("pause_menu_closed")
		
		$PauseMenu.visible = game_paused
		get_tree().paused = game_paused
		if OS.has_feature("web") or OS.has_feature("mobile"): $PauseMenu/hbcon/vbcon/btnExitOS.visible = false
		
		if $SettingsMenu.visible:
			save_settings()
			close_settings_menu()
func _on_btn_resume_pressed(): pause_game()
func _on_btn_open_settings_pressed(): open_settings_menu()
func _on_btn_exit_menu_pressed():
	$PauseMenu/vbconControls.visible = false
	$PauseMenu/vbconConfirmation.visible = true
	
	$PauseMenu/vbconConfirmation/vbconActions/btnCancel.grab_focus()
	
	confirmation_mode = 0
func _on_btn_exit_os_pressed():
	$PauseMenu/vbconControls.visible = false
	$PauseMenu/vbconConfirmation.visible = true
	
	$PauseMenu/vbconConfirmation/vbconActions/btnCancel.grab_focus()
	
	confirmation_mode = 1

var confirmation_mode :int = -1
func _on_btn_proceed_pressed():
	match confirmation_mode:
		-1:
			_on_btn_cancel_pressed()
		0: 
			pause_game()
			change_scene("res://scenes/menu.tscn", 1 , "cut")
		1:
			get_tree().quit()
func _on_btn_cancel_pressed():
	$PauseMenu/vbconControls.visible = true
	$PauseMenu/vbconConfirmation.visible = false
	
	match confirmation_mode:
		-1:
			$PauseMenu/vbconControls/vbconActions/btnResume.grab_focus()
		0: 
			$PauseMenu/vbconControls/vbconActions/btnExitMenu.grab_focus()
		1:
			$PauseMenu/vbconControls/vbconActions/btnExitOS.grab_focus()

signal settings_changed
signal settings_openned
signal settings_closed
func apply_settings():
	TranslationServer.set_locale(settings.lang)
	
	match settings.vsync:
		true:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		false:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			#  be careful with this, can crash if using vulkan renderer
			#  https://github.com/godotengine/godot/issues/70837
	match settings.fullscr:
		true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		false:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	match settings.low_gfx: #TODO
		true:
			pass
		false:
			pass
	
	AudioServer.set_bus_volume_db(1, linear_to_db(settings.sfx))
	AudioServer.set_bus_volume_db(2, linear_to_db(settings.mus))
	
	emit_signal("settings_changed")
var settings_file_path :String = OS.get_executable_path().get_base_dir().path_join("settings.data")
func load_settings():
	var dir = DirAccess.open("user://")
	if dir.file_exists(settings_file_path):
		var settings_file = FileAccess.open(settings_file_path, FileAccess.READ)
		
		var file_settings :Dictionary = settings_file.get_var()
		if file_settings.has_all(settings.keys()):
			settings = file_settings
		else:
			save_settings()
func save_settings():
	var settings_file = FileAccess.open(settings_file_path, FileAccess.WRITE)
	settings_file.store_var(settings)

func open_settings_menu():
	$SettingsMenu.visible = true
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	$SettingsMenu/bg.modulate.a = 0
	tween.tween_property($SettingsMenu/bg, "modulate:a", 1, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	$SettingsMenu/hbcon/vsep.remove_theme_constant_override("separation")
	$SettingsMenu/hbcon/vsep.add_theme_constant_override("separation", 30)
	tween.tween_property($SettingsMenu/hbcon/vsep, "theme_override_constants/separation", 50, .5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	$SettingsMenu/oSelectionHighlight.active = true
	await get_tree().process_frame # <- Don't touch, no idea why but it only works this way (again...)
	await get_tree().process_frame
	$SettingsMenu/hbcon/vbcon/actions/btnCloseSettings.grab_focus()
	
	setup_settings_menu()
	
	emit_signal("settings_openned")
func close_settings_menu():
	$SettingsMenu.visible = false
	
	$SettingsMenu/oSelectionHighlight.active = false
	
	$PauseMenu/vbconControls/vbconActions/btnOpenSettings.grab_focus()
	
	save_settings()
	emit_signal("settings_closed")
func setup_settings_menu():
	# skipped translation button bc theres only 1 availabe
	$SettingsMenu/hbcon/vbcon/lang/btnEN.disabled = true
	
	$SettingsMenu/hbcon/vbcon/vsync/chkbtnVsync.button_pressed = settings.vsync
	$SettingsMenu/hbcon/vbcon/fullscr/chkbtnFullscr.button_pressed = settings.fullscr
	
	match settings.low_gfx:
		true:
			_on_btn_gf_xlow_pressed()
		false:
			_on_btn_gf_xhigh_pressed()
	
	_on_sld_sfx_value_changed(settings.sfx)
	_on_sld_mus_value_changed(settings.mus)

func _on_btn_en_pressed():
	settings.lang = "en_US"
	$SettingsMenu/hbcon/vbcon/lang/btnEN.disabled = true

func _on_chkbtn_vsync_toggled(button_pressed):
	settings.vsync = button_pressed
	apply_settings()
func _on_chkbtn_fullscr_toggled(button_pressed):
	settings.fullscr = button_pressed
	apply_settings()

func _on_btn_gf_xhigh_pressed():
	$SettingsMenu/hbcon/vbcon/gfx/btnGFXhigh.disabled = true
	$SettingsMenu/hbcon/vbcon/gfx/btnGFXlow.disabled = false
	
	settings.low_gfx = false
	apply_settings()
func _on_btn_gf_xlow_pressed():
	$SettingsMenu/hbcon/vbcon/gfx/btnGFXhigh.disabled = false
	$SettingsMenu/hbcon/vbcon/gfx/btnGFXlow.disabled = true
	
	settings.low_gfx = true
	apply_settings()

func _on_sld_sfx_value_changed(value):
	$SettingsMenu/hbcon/vbcon/sfx/ccon/txtSfxSLD.text = str(value)
	
	settings.sfx = value
	apply_settings()
func _on_sld_mus_value_changed(value):
	$SettingsMenu/hbcon/vbcon/mus/ccon/txtMusSLD.text = str(value)
	
	settings.mus = value
	apply_settings()
