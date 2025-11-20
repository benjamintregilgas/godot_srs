extends Control
## Script for the ProfileSelect scene.
##
## Responsible for displaying existing profiles, and handling CRUD
## actions. Integrates with WindowManager for window sizing and ProfileManmager
## for data access.


@export var profile_container: Container ## Populated [Container] containing selectable profiles.
@export var open_profile_button: RichTextButton
@export var rename_profile_button: RichTextButton
@export var delete_profile_button: RichTextButton
@export var profile_line_edit: PackedScene
@export_group("Add Profile Window")
@export var add_profile_window: Window
@export var add_profile_line_edit: LineEdit
@export_group("Name Exists Window")
@export var name_exists_window: Window
@export_group("Rename Profile Window")
@export var rename_profile_window: Window
@export var rename_profile_line_edit: LineEdit
@export_group("Delete Profile Window")
@export var confirm_delete_profile_window: Window
@export var confirm_delete_profile_prompt: Label
@export_group("")
@export_category("Scene Paths")
@export_file_path("*.tscn", "*.scn") var main_screen_scene: String

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
		profile_line_edit_instance.gui_input.connect(
			func(event: InputEvent):
				if event is InputEventMouseButton and event.pressed:
					selected_profile = profile
					_refresh_options_buttons(false)
		)
		profile_container.add_child(profile_line_edit_instance)
	

#region Options / Windows

# Open Profile
func _on_open_profile_pressed() -> void:
	if selected_profile:
		ProfileManager.current_profile = selected_profile
		WindowManager.switch_scene(main_screen_scene)

# Add Profile
func _on_add_profile_pressed() -> void:
	_refresh_options_buttons(true)
	add_profile_window.popup_centered()

func _hide_add_profile_window() -> void:
	add_profile_line_edit.text = ""
	add_profile_window.hide()

func _on_add_profile_confirm_pressed() -> void:
	var new_name: String = add_profile_line_edit.text.strip_edges()
	if new_name == "":
		_hide_add_profile_window()
		return
	if ProfileManager.get_profile_by_name(new_name) != null:
		_hide_add_profile_window()
		name_exists_window.popup_centered()
		return
	ProfileManager.create_profile(new_name)
	_refresh_profile_list()
	_hide_add_profile_window()

# Name Already Exists Window
func _hide_name_exists_window() -> void:
	name_exists_window.hide()

# Rename Profile
func _on_rename_profile_pressed() -> void:
	_refresh_options_buttons(true)
	rename_profile_window.popup_centered()

func _hide_rename_profile_window() -> void:
	rename_profile_line_edit.text = ""
	rename_profile_window.hide()

func _on_rename_profile_confirm_pressed() -> void:
	var old_name: String = selected_profile.profile_name
	var new_name: String = rename_profile_line_edit.text.strip_edges()
	if new_name == "":
		_hide_rename_profile_window()
		return
	if ProfileManager.get_profile_by_name(new_name) != null:
		_hide_rename_profile_window()
		name_exists_window.popup_centered()
		return
	selected_profile = null
	if not ProfileManager.rename_profile(old_name, new_name):
		push_error("Could not rename profile '%s' to '%s'." % [old_name, new_name])
	_refresh_profile_list()
	_hide_rename_profile_window()


# Delete Profile
func _on_delete_profile_pressed() -> void:
	_refresh_options_buttons(true)
	confirm_delete_profile_prompt.text = "All cards, notes and media for the profile '%s' will be deleted. Are you sure?" % selected_profile.profile_name
	confirm_delete_profile_window.popup_centered()

func _hide_confirm_delete_profile_window() -> void:
	confirm_delete_profile_window.hide()

func _on_delete_profile_confirm_pressed() -> void:
	var target_profile: Profile = selected_profile
	selected_profile = null
	if not ProfileManager.delete_profile(target_profile):
		push_error("Failed to delete profile '%s'." % target_profile.profile_name)
	_refresh_profile_list()
	_hide_confirm_delete_profile_window()

# Quit
func _on_quit_pressed() -> void:
	get_tree().quit()

#endregion
