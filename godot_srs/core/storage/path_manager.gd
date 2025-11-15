class_name PathManager
extends Node
## Handles path management for both the Godot editor and an exported build.
##
## All methods will return a path depending on if the project is run in 
## the Godot editor or in an exported build.


## Returns folder path for profiles.
static func _get_profiles_folder() -> String:
	if OS.has_feature("editor"):
		return "res://data/profiles/"
	else:
		return "user://profiles/"

## Opens the folder path for profiles.
static func open_profiles_folder() -> String:
	var profiles_folder: String = _get_profiles_folder()
	DirAccess.make_dir_recursive_absolute(profiles_folder)
	return profiles_folder
