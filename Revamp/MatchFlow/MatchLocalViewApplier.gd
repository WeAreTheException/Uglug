extends Node
class_name MatchLocalViewApplier

@export var match_network_root: MatchNetworkRoot

@export var player_one_hand: PlayerHandRoot
@export var player_two_hand: PlayerHandRoot

@export_group("Attack Order Arrows")
@export var left_to_right_arrow: Sprite2D
@export var right_to_left_arrow: Sprite2D

@export var print_debug := false


func _ready() -> void:
	apply_local_view()


func apply_local_view() -> void:
	if match_network_root == null:
		return

	var local_owner := match_network_root.get_local_owner()

	if local_owner == SlotRow.SlotOwner.PLAYER:
		_show_player_one_view()
	else:
		_show_player_two_view()

	_apply_attack_order_arrows(local_owner)

	if print_debug:
		print("LOCAL VIEW OWNER: ", _get_owner_name(local_owner))

		if local_owner == SlotRow.SlotOwner.PLAYER:
			print("LOCAL ATTACK DIRECTION: LEFT TO RIGHT")
		else:
			print("LOCAL ATTACK DIRECTION: RIGHT TO LEFT")


func _show_player_one_view() -> void:
	_set_hand_visible(player_one_hand, true)
	_set_hand_visible(player_two_hand, false)


func _show_player_two_view() -> void:
	_set_hand_visible(player_one_hand, false)
	_set_hand_visible(player_two_hand, true)


func _set_hand_visible(
	hand: PlayerHandRoot,
	value: bool
) -> void:
	if hand == null:
		return

	hand.visible = value
	hand.set_hand_input_enabled(value)


func _apply_attack_order_arrows(
	local_owner: SlotRow.SlotOwner
) -> void:
	var is_player_one := (
		local_owner == SlotRow.SlotOwner.PLAYER
	)

	if left_to_right_arrow != null:
		left_to_right_arrow.visible = is_player_one

	if right_to_left_arrow != null:
		right_to_left_arrow.visible = not is_player_one


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
