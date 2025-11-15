extends Control
## Script for the ProfileSelect scene.
##
## Responsible for displaying existing profiles, and handling CRUD
## actions. Integrates with WindowManager for window sizing and ProfileManmager
## for data access.


## Populated [Container] containing selectable profiles.
@export var profile_container: Container


## Setup the window and populate/refresh profile list.
func _ready() -> void:
	WindowManager.set_window("Profiles", Vector2i(425, 355), true, Vector2i(425, 155))
