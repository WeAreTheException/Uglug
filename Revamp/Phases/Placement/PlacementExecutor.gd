extends Node
class_name PlacementExecutor

@export var placed_scale: Vector2 = Vector2.ONE

var controller: PlacementController = null


func setup(source_controller: PlacementController) -> void:
	controller = source_controller


func confirm_placement(
	card: CardRoot,
	slot: Slot,
	owner: SlotRow.SlotOwner
) -> Dictionary:
	if controller == null:
		return {}

	if not controller.is_valid_placement_slot(slot):
		return {}

	var board := controller.get_slots_root()

	if board == null:
		return {}

	card.setup_board_context(board)

	var placed := _assign_card_to_slot(card, slot)

	if not placed:
		return {}

	_consume_card_from_hand(card)
	_move_card_to_board_layer(card, slot, board)
	_snap_card_to_slot(card, slot)

	return _build_event(card, slot, owner, board)


func _assign_card_to_slot(card: CardRoot, slot: Slot) -> bool:
	if card.board_presence != null:
		return card.board_presence.enter_slot(slot, card)

	return slot.assign_card(card)


func _consume_card_from_hand(card: CardRoot) -> void:
	var hand := controller.get_player_hand()

	if hand == null:
		return

	hand.consume_primed_card_for_placement(card)
	hand.remove_card_from_hand(card)
	hand.enter_play_state()


func _move_card_to_board_layer(card: CardRoot, slot: Slot, board: SlotsRoot) -> void:
	var parent := board.spawned_card_parent

	if parent == null:
		parent = slot

	var saved_global_transform := card.global_transform

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	parent.add_child(card)
	card.global_transform = saved_global_transform


func _snap_card_to_slot(card: CardRoot, slot: Slot) -> void:
	card.global_position = slot.get_card_anchor_global_position()
	card.rotation_degrees = 0.0
	card.scale = placed_scale


func _build_event(
	card: CardRoot,
	slot: Slot,
	owner: SlotRow.SlotOwner,
	board: SlotsRoot
) -> Dictionary:
	return {
		"card": card,
		"card_data": card.card_data,
		"slot": slot,
		"slot_index": slot.slot_index,
		"slot_owner": board.get_owner_of_slot(slot),
		"placing_owner": owner,
		"opposing_slot": board.get_opposing_slot(slot),
		"adjacent_enemy_slots": board.get_adjacent_enemy_slots(slot)
	}
