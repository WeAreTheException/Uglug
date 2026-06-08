extends Node
class_name DeckSystemDebugInput

@export var deck_system_root: DeckSystemRoot
@export var enabled: bool = true

@export var p1_warrior_key: Key = KEY_J
@export var p1_worker_key: Key = KEY_K
@export var p2_warrior_key: Key = KEY_U
@export var p2_worker_key: Key = KEY_I


func _unhandled_input(event: InputEvent) -> void:
	if not enabled:
		return

	if deck_system_root == null:
		return

	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode == p1_warrior_key:
		deck_system_root.draw_warrior_for_player_one()

	if event.keycode == p1_worker_key:
		deck_system_root.draw_worker_for_player_one()

	if event.keycode == p2_warrior_key:
		deck_system_root.draw_warrior_for_player_two()

	if event.keycode == p2_worker_key:
		deck_system_root.draw_worker_for_player_two()
