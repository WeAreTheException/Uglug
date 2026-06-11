extends Node
class_name SteamManager

const APP_ID := 480

var steam_enabled: bool = false
var steam_id: int = 0
var steam_name: String = ""
var steam_avatar_texture: Texture2D = null


func _ready() -> void:
	initialize_steam()


func initialize_steam() -> void:
	if not Engine.has_singleton("Steam"):
		print("SteamManager: Steam singleton not found")
		return

	var init_response = Steam.steamInitEx(APP_ID, true)
	print("SteamManager: steamInitEx response = ", init_response)

	if not Steam.isSteamRunning():
		print("SteamManager: Steam is not running")
		return

	steam_enabled = true
	steam_id = Steam.getSteamID()
	steam_name = Steam.getPersonaName()
	steam_avatar_texture = get_avatar_texture_for_steam_id(steam_id)

	print("SteamManager: Steam initialized")
	print("SteamManager: Steam ID = ", steam_id)
	print("SteamManager: Steam username = ", steam_name)
	print("SteamManager: Steam avatar loaded = ", steam_avatar_texture != null)


func get_avatar_texture_for_steam_id(target_steam_id: int) -> Texture2D:
	if not steam_enabled:
		return null

	var avatar_handle: int = Steam.getMediumFriendAvatar(target_steam_id)

	if avatar_handle <= 0:
		print("SteamManager: Avatar handle unavailable for ", target_steam_id)
		return null

	var image_size: Dictionary = Steam.getImageSize(avatar_handle)
	var width: int = image_size.get("width", 0)
	var height: int = image_size.get("height", 0)

	if width <= 0 or height <= 0:
		print("SteamManager: Avatar image size invalid for ", target_steam_id)
		return null

	var image_response: Dictionary = Steam.getImageRGBA(avatar_handle)
	var image_data: PackedByteArray = image_response.get("buffer", PackedByteArray())

	if image_data.is_empty():
		print("SteamManager: Avatar image data empty for ", target_steam_id)
		return null

	var image := Image.create_from_data(
		width,
		height,
		false,
		Image.FORMAT_RGBA8,
		image_data
	)

	return ImageTexture.create_from_image(image)
