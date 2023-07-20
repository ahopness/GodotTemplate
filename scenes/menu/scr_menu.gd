extends Control

const bg_dim_alpha :float = .5
const submenu_dim_alpha :float = .7

func _ready():
	if OS.has_feature("web") or OS.has_feature("mobile"): $actions/btnExit.visible = false
	
	var version = VersionDescriber.new()
	$txtVersion.text = version.get_game_version()

var can_start :bool = false
func _on_anm_animation_finished(anim_name): can_start = true
func _on_btn_start_pressed():
	if can_start:
		$action.visible = true
		$oSelectionHighlight.reparent($action)
		$action.move_child(get_node("action/oSelectionHighlight"), 1)
		
		$btnStart.visible = false
		$action/vbcon/btnNewGame.grab_focus()
		
		var tween = create_tween()
		$action/bg.color.a = 0
		tween.tween_property($action/bg, "color:a", bg_dim_alpha, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _on_btn_new_game_pressed():
	pass # Replace with function body.
func _on_btn_load_game_pressed():
	pass # Replace with function body.
func _on_btn_open_settings_pressed():
	Manager.open_settings_menu()
	
	get_node("action/oSelectionHighlight").active = false
	await Manager.settings_closed
	get_node("action/oSelectionHighlight").active = true
	$action/vbcon/btnOpenSettings.grab_focus()
func _on_btn_about_pressed():
	$about.visible = true
	get_node("action/oSelectionHighlight").reparent($about)
	$about.move_child(get_node("about/oSelectionHighlight"), 1)
	
	action_disable_focussing()
	
	$about/vbcon/btnExitAbout.grab_focus()
	
	var tween = create_tween()
	$about/bg.color.a = 0
	tween.tween_property($about/bg, "color:a", submenu_dim_alpha, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
func _on_btn_credits_pressed():
	$credits.visible = true
	get_node("action/oSelectionHighlight").reparent($credits)
	$credits.move_child(get_node("credits/oSelectionHighlight"), 1)
	
	action_disable_focussing()
	
	$credits/vbcon/btnExitCredits.grab_focus()
	
	var tween = create_tween()
	$credits/bg.color.a = 0
	tween.tween_property($credits/bg, "color:a", submenu_dim_alpha, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
func _on_btn_exit_pressed():
	get_tree().quit()

func _on_btn_exit_about_pressed():
	$about.visible = false
	get_node("about/oSelectionHighlight").reparent($action)
	$action.move_child(get_node("action/oSelectionHighlight"), 1)
	
	action_enable_focussing()
	
	$action/vbcon/btnAbout.grab_focus()

func _on_btn_exit_credits_pressed():
	$credits.visible = false
	get_node("credits/oSelectionHighlight").reparent($action)
	$action.move_child(get_node("action/oSelectionHighlight"), 1)
	
	action_enable_focussing()
	
	$action/vbcon/btnCredits.grab_focus()

func action_disable_focussing():
	for action in $action/vbcon.get_children():
		action.focus_mode = FOCUS_NONE
func action_enable_focussing():
	for action in $action/vbcon.get_children():
		action.focus_mode = FOCUS_ALL
