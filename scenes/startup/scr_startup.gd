# SCENE: Startup
#
# DESC.: Used for initializing and compiling shaders. Can be
# used for showing your studio's logo with animations or 
# initializing services.
#
# SHADER COMPILATION HOW-TO: (not automated yet, sry :/)
# 	1st: save all your game's materials to the "res://vfx/materials/",
# 	2nd: insert all your material files to 'spatial_materials' and
# 'canvas_materials' arrays (using the Object type variable),
# 	Done!

extends Control

export var spatial_materials :Array
export var canvas_materials :Array

const IDLE_TIME :float = 0.2

func _ready():
	$CompShader.visible = true
	
	var comp_stage
	comp_stage = comp_spatial_shaders()
	if comp_stage is GDScriptFunctionState: yield(comp_stage, "completed")
	comp_stage = comp_canvas_shaders()
	if comp_stage is GDScriptFunctionState: yield(comp_stage, "completed")
	
	$CompShader.visible = false
	
	Manager.change_scene("res://scenes/menu.tscn")

func comp_spatial_shaders():
	var count :int = 0
	
	for mat in spatial_materials:
		if mat is Material:
			count += 1
			$CompShader/txtProgress.text = str(count) + "/" + str(spatial_materials.size())
			
			$CompShader/spatialWorld/mesh.material = mat
			yield(get_tree().create_timer(IDLE_TIME), "timeout")
func comp_canvas_shaders():
	var count :int = 0
	
	for mat in canvas_materials:
		if mat is Material:
			count += 1
			$CompShader/txtProgress.text = str(count) + "/" + str(canvas_materials.size())
			
			$CompShader/canvasWorld/tex.material = mat
			yield(get_tree().create_timer(IDLE_TIME), "timeout")
