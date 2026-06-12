extends Node
class_name LobbyDebugHandler


func _ready() -> void:
	if not GDSync.client_joined.is_connected(_on_client_joined):
		GDSync.client_joined.connect(_on_client_joined)

	if not GDSync.client_left.is_connected(_on_client_left):
		GDSync.client_left.connect(_on_client_left)


func _on_client_joined(client_id: int) -> void:
	print("Client joined lobby: ", client_id)
	print("Username: ", GDSync.player_get_username(client_id, "Unknown"))


func _on_client_left(client_id: int) -> void:
	print("Client left lobby: ", client_id)
