extends Control
## Script for the ProfileSelect scene.
##
## Responsible for displaying existing profiles, and handling CRUD
## actions. Integrates with WindowManager for window sizing and ProfileManmager
## for data access.


@export var profile_container: Container ## Populated [Container] containing selectable profiles.
@export var open_profile_button: Button
@export var rename_profile_button: Button
@export var delete_profile_button: Button
@export var profile_line_edit: PackedScene


## Highlighted profile in [profile_container].
var selected_profile: Profile = null


## Setup the window and refresh profile list.
func _ready() -> void:
	WindowManager.set_window("Profiles", Vector2i(425, 355), true, Vector2i(425, 155))
	_refresh_profile_list()


## Refreshes the options with [Button.disabled] equal to [param disabled].
func _refresh_options_buttons(disabled: bool) -> void:
	open_profile_button.disabled = disabled
	rename_profile_button.disabled = disabled
	delete_profile_button.disabled = disabled


## Refreshes the profile list with all existing profiles.
func _refresh_profile_list() -> void:
	# Stop selecting any profiles.
	selected_profile = null
	# Refresh the list.
	_refresh_options_buttons(true)
	for node in profile_container.get_children():
		node.queue_free()
	# Sort profiles alphabetically.
	var sorted_profiles: Array[Profile] = ProfileManager.profiles
	sorted_profiles.sort_custom(
		func(a, b):
			return a.profile_name.to_lower() < b.profile_name.to_lower()
	)
	# Populate profiles list.
	for profile in sorted_profiles:
		var profile_line_edit_instance = profile_line_edit.instantiate() as LineEdit
		profile_line_edit_instance.text = profile.profile_name
		profile_line_edit_instance.focus_entered.connect(
			func():
				selected_profile = profile
				_refresh_options_buttons(false)
		)
		profile_container.add_child(profile_line_edit_instance)
	
