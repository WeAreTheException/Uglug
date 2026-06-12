extends RefCounted
class_name MainMenuLobbyMapPresenter


func build_lobbies_for_map(
	current_lobbies: Array,
	own_lobby_info: Dictionary,
	is_hosting: bool
) -> Array:
	var lobbies := current_lobbies.duplicate()

	if not is_hosting:
		return lobbies

	if own_lobby_info.is_empty():
		return lobbies

	var own_lobby := own_lobby_info.duplicate()
	own_lobby["is_own_lobby"] = true

	var own_lobby_name: String = own_lobby.get("lobby_name", "")

	for i in range(lobbies.size()):
		if lobbies[i].get("lobby_name", "") == own_lobby_name:
			lobbies[i] = own_lobby
			return lobbies

	lobbies.append(own_lobby)
	return lobbies
