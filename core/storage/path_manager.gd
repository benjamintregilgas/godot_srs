extends Node
class_name PathManager
## Handles path management for both the Godot editor and an exported build.
##
## All methods will return a path depending on if the project is run in 
## the Godot editor or in an exported build.


## Returns folder path for profiles.
static func get_profiles_folder() -> String:
	if Engine.is_editor_hint():
		return "res://data/profiles/"
	else:
		return "user://profiles/"
