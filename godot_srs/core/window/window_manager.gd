extends Node
## Global autoload responsible for managing Window changes.
##
## Handles setting Window title and size, and UI force updates.


## Sets the window's title and size. [br]
## Performs a UI refresh to fix layout issues after resizing. [br]
func set_window(title: String, size: Vector2i, centered: bool = true) -> void:
	# Wait for Godot-specific initialization before handling visual window changes.
	await get_tree().process_frame
	# Set title and size.
	DisplayServer.window_set_title(title)
	DisplayServer.window_set_size(size)
	# Center window on current display.
	if centered:
		var screen_size: Vector2i = DisplayServer.screen_get_size()
		var window_size: Vector2i = DisplayServer.window_get_size()
		var current_screen: int = DisplayServer.SCREEN_OF_MAIN_WINDOW
		var screen_center = (screen_size - window_size) / 2
		var new_position: Vector2i = DisplayServer.screen_get_position(current_screen) + screen_center
		DisplayServer.window_set_position(new_position)
	# Ensure control nodes are updated upon resize.
	await get_tree().process_frame
	var root_control: Control = get_tree().current_scene as Control
	if root_control:
		root_control.size = Vector2(size)


## Switches the current scene to [param path] if it exists.
func switch_scene(path: String) -> void:
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		push_error("Scene not found: '%s'." % path)
