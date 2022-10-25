extends Node
class_name VersionDescriber

func game_version() -> String:
	var version :String = "v"
	
	version += ProjectSettings.get("application/config/version")
	
	if OS.has_feature("pc"):
		version += ".desktop"
	elif OS.has_feature("mobile"):
		version += ".mobile"
	elif OS.has_feature("web"):
		version += ".web"
	
	if OS.has_feature("debug"):
		version += ".dev"
	
	return version
