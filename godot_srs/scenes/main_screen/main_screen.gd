extends Control
## Script for the MainScreen scene.
##
## Responsible for navigation of all other features within GodotSRS.


@export_group("Window Management")
@export var WINDOW_SIZE: Vector2i = Vector2i(1920, 1080)
@export_subgroup("Limits")
@export var MIN_WINDOW_SIZE: Vector2i = Vector2i(160, 90)
@export var MAX_WINDOW_SIZE: Vector2i = Vector2i(1920, 1080)

## Setup the window.
func _ready() -> void:
	var current_profile_name: String = ProfileManager.current_profile.profile_name
	WindowManager.set_window(
		"%s - GodotSRS" % current_profile_name,
		Vector2i(1920, 1080),
		true,
		MIN_WINDOW_SIZE,
		MAX_WINDOW_SIZE,
	)
