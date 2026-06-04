extends Node
class_name PlacementExecutor

@export var placed_scale: Vector2 = Vector2.ONE

var controller: PlacementController = null
var board_mover := PlacementCardBoardMoverHelper.new()
var event_builder := PlacementEventBuilderHelper.new()


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

	if not _assign_card_to_slot(card, slot):
		return {}

	_release_card_from_hand(card)
	board_mover.move_card_to_board_layer(card, slot, board)
	board_mover.snap_card_to_slot(card, slot, placed_scale)

	return event_builder.build_event(board, card, slot, owner)


func _assign_card_to_slot(card: CardRoot, slot: Slot) -> bool:
	if card.board_presence != null:
		return card.board_presence.enter_slot(slot, card)

	return slot.assign_card(card)


func _release_card_from_hand(card: CardRoot) -> void:
	var hand := controller.get_player_hand()

	if hand != null:
		hand.release_primed_card_for_placement(card)
