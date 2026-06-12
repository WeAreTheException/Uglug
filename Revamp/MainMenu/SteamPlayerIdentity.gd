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
