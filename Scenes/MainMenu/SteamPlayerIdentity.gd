extends Node
class_name SteamPlayerIdentity

@export var steam_manager: SteamManager


func get_display_name(fallback_name: String) -> String:
	if steam_manager == null:
		return fallback_name

	if not steam_manager.steam_enabled:
		return fallback_name

	if steam_manager.steam_name.strip_edges() == "":
		return fallback_name

	return steam_manager.steam_name


func get_steam_id() -> int:
	if steam_manager == null:
		return 0

	if not steam_manager.steam_enabled:
		return 0

	return steam_manager.steam_id


func get_avatar_texture_for_steam_id(steam_id: int) -> Texture2D:
	if steam_manager == null:
		return null

	if steam_id <= 0:
		return null

	return steam_manager.get_avatar_texture_for_steam_id(steam_id)
