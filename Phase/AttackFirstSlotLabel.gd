extends Node
class_name AttackFirstSlotLabels

@export var turn_manager: Node

# These are local-screen labels:
# player_one_label = my side label
# player_two_label = opponent side label
@export var player_one_label: Label
@export var player_two_label: Label

var is_ready_to_show := false


func _ready() -> void:
	hide_both()
	call_deferred("_setup")


func _setup() -> void:
	if turn_manager == null:
		print("AttackFirstSlotLabels blocked: turn_manager is null")
		return

	if turn_manager.has_signal("attacking_first_changed"):
		if not turn_manager.attacking_first_changed.is_connected(show_attacking_first):
			turn_manager.attacking_first_changed.connect(show_attacking_first)

	while int(turn_manager.get("player_one_id")) == -1 or int(turn_manager.get("player_two_id")) == -1:
		await get_tree().process_frame

	is_ready_to_show = true

	var current_first_id := int(turn_manager.get("current_first_id"))

	print("AttackFirstSlotLabels ready")
	print("local_id = ", int(GDSync.get_client_id()))
	print("player_one_id = ", int(turn_manager.get("player_one_id")))
	print("player_two_id = ", int(turn_manager.get("player_two_id")))
	print("current_first_id = ", current_first_id)

	show_attacking_first(current_first_id)


func show_attacking_first(attacking_first_id: int) -> void:
	if turn_manager == null:
		return

	var local_id := int(GDSync.get_client_id())

	print("show attacking first: ", attacking_first_id, " local_id: ", local_id)

	if attacking_first_id == local_id:
		show_player_one()
	else:
		show_player_two()


func show_player_one() -> void:
	print("SHOW LOCAL PLAYER ATTACK FIRST LABEL")

	if player_one_label != null:
		player_one_label.visible = true
		player_one_label.modulate.a = 1.0
	else:
		print("player_one_label is null")

	if player_two_label != null:
		player_two_label.visible = false
	else:
		print("player_two_label is null")


func show_player_two() -> void:
	print("SHOW OPPONENT ATTACK FIRST LABEL")

	if player_one_label != null:
		player_one_label.visible = false
	else:
		print("player_one_label is null")

	if player_two_label != null:
		player_two_label.visible = true
		player_two_label.modulate.a = 1.0
	else:
		print("player_two_label is null")


func hide_both() -> void:
	if player_one_label != null:
		player_one_label.visible = false

	if player_two_label != null:
		player_two_label.visible = false
