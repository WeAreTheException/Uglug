extends Node
class_name SteamPlayerIdentity

@export var steam_manager: SteamManager


func get_display_name(fallback_name: String) -> String:
	var clean_fallback := fallback_name.strip_edges()

	if clean_fallback == "":
		clean_fallback = "Player"

	if steam_manager == null:
		return clean_fallback

	if not steam_manager.steam_enabled:
		return clean_fallback

	var clean_steam_name := steam_manager.steam_name.strip_edges()

	if clean_steam_name == "":
		return clean_fallback

	return clean_steam_name


func get_display_name_for_id(player_id: int) -> String:
	var fallback_name := PlaceholderPlayerNames.get_name_for_id(player_id)
	return get_display_name(fallback_name)
