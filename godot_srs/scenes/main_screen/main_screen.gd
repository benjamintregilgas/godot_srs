extends Control
## Script for the MainScreen scene.
##
## Responsible for navigation of all other features within GodotSRS.



@export var content: Control
@export var disclaimer: Control
@export var navigation_bar: Control

@export_category("Scene Paths")
@export_file_path("*.tscn", "*.scn") var profile_select_scene: String

## Setup the window.
func _ready() -> void:
	if navigation_bar.has_signal("refresh_requested"):
		navigation_bar.refresh_requested.connect(_refresh_screen)
	
	_refresh_screen()


func _create_profile_select_window() -> void:
	WindowManager.create_window(profile_select_scene, "Profiles", "profiles",
				Vector2i(425, 355), Vector2i(425, 155),
		)


func _refresh_screen() -> void:
	var profile_available: bool = ProfileManager.current_profile != null
	content.visible = profile_available
	disclaimer.visible = not profile_available
	
	# Open the Profile Select dialogue if no current profile is present.
	if not profile_available:
		get_tree().root.title = "GodotSRS"
		_create_profile_select_window()
	else:
		get_tree().root.title = "%s - GodotSRS" % ProfileManager.current_profile.profile_name
