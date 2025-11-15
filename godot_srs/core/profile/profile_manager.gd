extends Node
## Global autoload responsible for managing Profile resources.
##
## Handles CRUD responsibilities (Create, Read, Update, Delete) for profiles.
## Emits signals when profile list changes.


## Emitted whenever a profile is added, removed, or updated.
signal profile_list_changed

## Currently loaded profiles in memory.
@export var profiles: Array[Profile] = []

## Currently loaded profile for app usage.
var current_profile: Profile = null


func _ready() -> void:
	load_all_profiles()


#region Helper Functions

## Returns [code]true[/code] if profile_name does not contain invalid characters.
func is_valid_profile_name(profile_name: String) -> bool:
	var invalid_chars = ["\\", "/", ":", "*", "?", "\"", "<", ">", "|"]
	for c in invalid_chars:
		if profile_name.find(c) != -1:
			return false
	return true


## Returns the [Profile] instance with the given name, or [code]null[/code] if not found.
func get_profile_by_name(profile_name: String) -> Profile:
	for profile in profiles:
		if profile.profile_name == profile_name:
			return profile
	push_warning("Failed to load profile '%s'." % profile_name)
	return null


## Loads all profiles from profile folder.
func load_all_profiles() -> void:
	var profiles_folder: String = PathManager.open_profiles_folder()
	var directory: DirAccess = DirAccess.open(profiles_folder)
	if directory == null:
		push_error("Failed to open profiles directory: '%s'." % profiles_folder)
		return
	directory.list_dir_begin()
	var file_name: String = directory.get_next()
	while file_name != "":
		if file_name != "." and file_name != ".." and file_name.ends_with(".tres"):
			load_profile(file_name.replace(".tres", ""))
		file_name = directory.get_next()
	directory.list_dir_end()

#endregion

#region CRUD Operations

## Creates a new profile with the given [param profile_name] and saves into memory.
## Returns the Profile instance created, and null if an error occured.
func create_profile(profile_name: String) -> Profile:
	if get_profile_by_name(profile_name) != null:
		push_error("Profile with name '%s' already exists." % profile_name)
		return null
	if not is_valid_profile_name(profile_name):
		push_error("Invalid profile_name: '%s'." % profile_name)
		return null
	var profile: Profile = Profile.new()
	profile.profile_name = profile_name
	var save_error: Error = save_profile(profile)
	if save_error != OK:
		push_error("Failed to save profile '%s'." % profile_name)
		return null
	profiles.append(profile)
	profile_list_changed.emit()
	return profile


## Saves the given [param profile] to disk.
## Returns [code]OK[/code] on success, error code on failure.
func save_profile(profile: Profile) -> Error:
	var profiles_folder: String = PathManager.open_profiles_folder()
	var profile_save_path: String = profiles_folder + profile.profile_name + ".tres"
	return ResourceSaver.save(profile, profile_save_path)


## Loads a profile with [param profile_name] from disk.
## Returns the [Profile] instance or null if an error occured.
func load_profile(profile_name: String) -> Profile:
	var profiles_folder: String = PathManager.open_profiles_folder()
	var profile_save_path: String = profiles_folder + profile_name + ".tres"
	var profile: Profile = ResourceLoader.load(profile_save_path) as Profile
	if profile == null:
		return null
	if get_profile_by_name(profile_name) != null:
		push_warning("Profile with same name '%s' already loaded." % profile_name)
		return get_profile_by_name(profile_name)
	profiles.append(profile)
	profile_list_changed.emit()
	return profile


## Deletes a profile with name [param profile_name] from memory and disk.
## Returns [code]true[/code] if deletion succeeded.
func delete_profile(profile_name: String) -> bool:
	var profile: Profile = get_profile_by_name(profile_name)
	if profile == null:
		return false
	profiles.erase(profile)
	profile_list_changed.emit()
	var profiles_folder: String = PathManager.open_profiles_folder()
	var profile_save_path: String = profiles_folder + profile_name + ".tres"
	var dir_access: DirAccess = DirAccess.open(profiles_folder)
	if dir_access == null or not dir_access.file_exists(profile_save_path):
		return true
	return dir_access.remove(profile_save_path) == OK


## Renames a profile from [param old_name] to [param new_name] in memory and disk.
## Returns [code]true[/code] on success, [code]false[/code] on failure.
func rename_profile(old_name: String, new_name: String) -> bool:
	var profile: Profile = get_profile_by_name(old_name)
	if profile == null:
		return false
	if get_profile_by_name(new_name) != null:
		push_error("Profile with name '%s' already exists." % new_name)
		return false
	if not is_valid_profile_name(new_name):
		push_error("Invalid profile_name: '%s'." % new_name)
		return false
	var old_profile_name: String = profile.profile_name
	profile.profile_name = new_name
	var save_error: Error = save_profile(profile)
	if save_error != OK:
		push_error("Failed to save renamed profile '%s'." % new_name)
		profile.profile_name = old_profile_name
		return false
	if not delete_profile(old_profile_name):
		push_warning("Old profile '%s' could not be deleted.")
	profile_list_changed.emit()
	return true

#endregion
