extends Node
class_name MainMenuMapFlow

signal public_lobby_clicked(lobby_info: Dictionary)
signal private_lobby_clicked(lobby_info: Dictionary)
signal own_lobby_clicked(lobby_info: Dictionary)

@export var state_manager: MainMenuStateManager
@export var lobby_icon_spawner: LobbyIconSpawner

var current_lobbies: Array = []
var hosted_lobby_name := ""
var hosted_lobby_info: Dictionary = {}
var lobby_map_presenter := MainMenuLobbyMapPresenter.new()


func _ready() -> void:
	lobby_icon_spawner.lobby_icon_clicked.connect(_on_lobby_icon_clicked)


func handle_lobbies_updated(lobbies: Array) -> void:
	current_lobbies = lobbies
	print("Joinable lobbies found: ", lobbies.size())
	_update_lobby_map()


func set_hosted_lobby(lobby_name: String, lobby_info: Dictionary) -> void:
	hosted_lobby_name = lobby_name
	hosted_lobby_info = lobby_info
	_update_lobby_map()


func clear_hosted_lobby() -> void:
	hosted_lobby_name = ""
	hosted_lobby_info = {}
	_update_lobby_map()


func get_current_lobbies() -> Array:
	return current_lobbies


func _on_lobby_icon_clicked(lobby_info: Dictionary) -> void:
	var lobby_name: String = lobby_info.get("lobby_name", "")

	if state_manager.is_hosting() and lobby_name == hosted_lobby_name:
		own_lobby_clicked.emit(lobby_info)
		return

	if lobby_info.get("is_private", false):
		private_lobby_clicked.emit(lobby_info)
		return

	public_lobby_clicked.emit(lobby_info)


func _update_lobby_map() -> void:
	var map_lobbies := lobby_map_presenter.build_lobbies_for_map(
		current_lobbies,
		hosted_lobby_info,
		state_manager.is_hosting()
	)

	lobby_icon_spawner.update_lobbies(map_lobbies)
