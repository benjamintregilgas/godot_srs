extends PanelContainer


signal refresh_requested

@export_file_path("*.tscn", "*.scn") var profile_select_scene: String
@export var file_nav_menu: MenuButton


func _ready() -> void:
	file_nav_menu.get_popup().id_pressed.connect(file_nav_menu_pressed)


func file_nav_menu_pressed(id: int) -> void:
	match id:
		0: # Switch Profile
			ProfileManager.current_profile = null
			refresh_requested.emit()
		1: # Exit
			get_tree().quit()
		_:
			return
