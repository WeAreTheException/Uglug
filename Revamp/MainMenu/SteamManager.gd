extends Node
class_name SteamManager

@export var print_steam_debug: bool

const APP_ID := 480

var steam_enabled: bool = false
var steam_id: int = 0
var steam_name: String = ""

func _ready() -> void:
	initialize_steam()

func initialize_steam() -> void:
	if not Engine.has_singleton("Steam"):
		if print_steam_debug:
			print("SteamManager: Steam singleton not found")
		return

	var init_response = Steam.steamInitEx(APP_ID, true)
	if print_steam_debug:
		print("SteamManager: steamInitEx response = ", init_response)

	if not Steam.isSteamRunning():
		if print_steam_debug:
			print("SteamManager: Steam is not running")
		return

	steam_enabled = true
	steam_id = Steam.getSteamID()
	steam_name = Steam.getPersonaName()

	if print_steam_debug:
		print("SteamManager: Steam initialized")
		print("SteamManager: Steam ID = ", steam_id)
		print("SteamManager: Steam username = ", steam_name)
