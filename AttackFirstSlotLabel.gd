extends Node
class_name AttackFirstSlotLabels

@export var turn_manager: TurnManager

@export var player_one_label: Label
@export var player_two_label: Label

var player_one_is_attacking_first: bool = true

func _ready() -> void:
	hide_both()

	if turn_manager != null:
		turn_manager.attacking_first_changed.connect(show_attacking_first)

		if turn_manager.current_first_id != -1:
			show_attacking_first(turn_manager.current_first_id)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_5:
			debug_swap()


func debug_swap() -> void:
	player_one_is_attacking_first = not player_one_is_attacking_first

	if player_one_is_attacking_first:
		show_player_one()
	else:
		show_player_two()


func show_attacking_first(client_id: int) -> void:
	if turn_manager == null:
		return

	if client_id == turn_manager.player_one_id:
		player_one_is_attacking_first = true
		show_player_one()

	elif client_id == turn_manager.player_two_id:
		player_one_is_attacking_first = false
		show_player_two()


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
