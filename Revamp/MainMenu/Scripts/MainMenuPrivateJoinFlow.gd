extends Node
class_name MainMenuPrivateJoinFlow

signal private_join_requested(lobby_info: Dictionary, passcode: String)

@export var join_private_popup: JoinPrivatePopup

var pending_private_lobby_info: Dictionary = {}


func _ready() -> void:
	join_private_popup.enter_requested.connect(_on_passcode_entered)
	join_private_popup.close_requested.connect(_on_popup_closed)


func open_for_lobby(lobby_info: Dictionary) -> void:
	pending_private_lobby_info = lobby_info
	join_private_popup.open()


func clear() -> void:
	pending_private_lobby_info = {}
	join_private_popup.close()


func show_incorrect_password() -> void:
	join_private_popup.flash_incorrect_password()


func show_lobby_missing() -> void:
	join_private_popup.flash_lobby_no_longer_exists()


func _on_passcode_entered(passcode: String) -> void:
	if pending_private_lobby_info.is_empty():
		print("No private lobby selected.")
		return

	private_join_requested.emit(pending_private_lobby_info, passcode)


func _on_popup_closed() -> void:
	pending_private_lobby_info = {}
