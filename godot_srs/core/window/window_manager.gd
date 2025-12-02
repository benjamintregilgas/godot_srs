extends Node
## Global autoload responsible for managing Window changes.
##
## Handles setting Window title and size, and UI force updates.


## Sets the window's title and size. [br]
## Performs a UI refresh to fix layout issues after resizing. [br]
func set_window(title: String, size: Vector2i, min_size: Vector2i = Vector2i.ZERO, max_size: Vector2i = Vector2i.ZERO) -> void:
	# Wait for Godot-specific initialization before handling visual window changes.
	await get_tree().process_frame
	# Set title and size.
	DisplayServer.window_set_title(title)
	DisplayServer.window_set_size(size)
	# Set window min and max size.
	if min_size != Vector2i.ZERO:
		DisplayServer.window_set_min_size(min_size)
	if max_size != Vector2i.ZERO:
		DisplayServer.window_set_max_size(max_size)
	# Center window on current display.
	_center_window()
	#await get_tree().process_frame
	#_refresh_root_control()


## Switches the current scene to [param path] if it exists.
func switch_scene(path: String) -> void:
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
		# Ensure control nodes are updated upon resize.
		# Give Godot two frames to process:
				# 1. scene attachment, and
				# 2. layout settling.
		await get_tree().process_frame
		await get_tree().process_frame
		_refresh_root_control()
		_center_window()
	else:
		push_error("Scene not found: '%s'." % path)


func _center_window() -> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var window_size: Vector2i = DisplayServer.window_get_size()
	var current_screen: int = DisplayServer.SCREEN_OF_MAIN_WINDOW
	var screen_center = (screen_size - window_size) / 2
	var new_position: Vector2i = DisplayServer.screen_get_position(current_screen) + screen_center
	DisplayServer.window_set_position(new_position)


func _refresh_root_control() -> void:
	var root_control: Control = get_tree().current_scene as Control
	if root_control:
		root_control.size = DisplayServer.window_get_size()
		root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root_control.queue_redraw()
		#root_control.minimum_size_changed.emit()
