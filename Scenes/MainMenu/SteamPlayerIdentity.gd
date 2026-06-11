extends Node
class_name SteamPlayerIdentity


func get_display_name(fallback_name: String) -> String:
	if not Engine.has_singleton("Steam"):
		return fallback_name

	var steam = Engine.get_singleton("Steam")

	if not steam.has_method("getPersonaName"):
		return fallback_name

	var steam_name: String = steam.getPersonaName()

	if steam_name.strip_edges() == "":
		return fallback_name

	return steam_name
