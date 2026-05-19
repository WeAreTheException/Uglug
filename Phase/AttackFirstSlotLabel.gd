extends Node
class_name AttackFirstSlotLabels

@export var turn_manager: Node

@export var player_one_label: Label
@export var player_two_label: Label

var player_one_is_attacking_first: bool = true


func _ready() -> void:
	hide_both()
	call_deferred("_connect_turn_manager")


func _connect_turn_manager() -> void:
	if turn_manager == null:
		print("AttackFirstSlotLabels blocked: turn_manager is null")
		return

	if turn_manager.has_signal("attacking_first_changed"):
		if not turn_manager.attacking_first_changed.is_connected(show_attacking_first):
			turn_manager.attacking_first_changed.connect(show_attacking_first)

	var current_first_id := int(turn_manager.get("current_first_id"))

	if current_first_id != -1:
		show_attacking_first(current_first_id)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_5:
			if turn_manager != null and turn_manager.has_method("request_flip_attacking_first"):
				turn_manager.call("request_flip_attacking_first")


func show_attacking_first(client_id: int) -> void:
	if turn_manager == null:
		return

	var player_one_id := int(turn_manager.get("player_one_id"))
	var player_two_id := int(turn_manager.get("player_two_id"))

	if client_id == player_one_id:
		player_one_is_attacking_first = true
		show_player_one()
		return

	if client_id == player_two_id:
		player_one_is_attacking_first = false
		show_player_two()
		return

	hide_both()


func show_player_one() -> void:
	if player_one_label != null:
		player_one_label.visible = true

	if player_two_label != null:
		player_two_label.visible = false


func show_player_two() -> void:
	if player_one_label != null:
		player_one_label.visible = false

	if player_two_label != null:
		player_two_label.visible = true


func hide_both() -> void:
	if player_one_label != null:
		player_one_label.visible = false

	if player_two_label != null:
		player_two_label.visible = false
