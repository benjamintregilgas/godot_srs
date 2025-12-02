extends Node
## Global autoload responsible for managing Windows.
##
## Handles creating and closing windows with content.


# Currently managed windows. (Array does not include root window, that is managed by Godot.)
var _windows: Dictionary[String, Window] = {}


func create_window(scene_path: String, title: String, key: String,
		size: Vector2i, min_size: Vector2i = Vector2i.ZERO, max_size: Vector2i = Vector2i.ZERO
		) -> Window:
	# If the window already exists, just focus to specified window.
	if _windows.has(key):
		_windows[key].grab_focus()
		return _windows[key]
	# Ensure desired content exists.
	if not ResourceLoader.exists(scene_path):
		push_error("Scene not found: '%s'." % scene_path)
		return null
	# Create the window.
	var new_window: Window = Window.new()
	new_window.hide() # Hiding is necessary for changes to apply.
	new_window.force_native = true
	new_window.transient = true
	new_window.title = title
	new_window.size = size
	new_window.min_size = min_size
	new_window.max_size = max_size
	# Add scene content to window.
	var content: Node = load(scene_path).instantiate()
	new_window.add_child(content)
	# Place and add the window.
	_center_window(new_window)
	get_tree().root.add_child.call_deferred(new_window)
	new_window.popup()
	# Connect close requested from each window.
	new_window.close_requested.connect(close_window.bind(key))
	_windows[key] = new_window
	return new_window


func close_window(key: String) -> void:
	if _windows.has(key):
		_windows[key].queue_free()
		_windows.erase(key)


func _center_window(window: Window) -> void:
	var current_screen: int = DisplayServer.SCREEN_OF_MAIN_WINDOW
	var main_screen: int = DisplayServer.window_get_current_screen(current_screen)
	var screen_pos: Vector2i = DisplayServer.screen_get_position(main_screen)
	var screen_size: Vector2i = DisplayServer.screen_get_size(main_screen)
	var center_pos: Vector2i = screen_pos + (screen_size - window.size) / 2
	window.position = center_pos
