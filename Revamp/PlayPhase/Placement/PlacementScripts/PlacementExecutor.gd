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

	return confirm_network_placement(
		card,
		slot,
		owner,
		controller.get_player_hand()
	)


func confirm_network_placement(
	card: CardRoot,
	slot: Slot,
	owner: SlotRow.SlotOwner,
	source_hand: PlayerHandRoot
) -> Dictionary:
	if controller == null:
		return {}

	var board := controller.get_slots_root()

	if board == null:
		return {}

	if card == null or slot == null:
		return {}

	card.setup_board_context(board)

	_release_card_from_source_hand(card, source_hand)

	if not _assign_card_to_slot(card, slot):
		return {}

	board_mover.move_card_to_board_layer(card, slot, board)
	board_mover.snap_card_to_slot(card, slot, placed_scale)

	var event: Dictionary = event_builder.build_event(board, card, slot, owner)

	_notify_card_placed(card, slot, owner)

	return event


func _assign_card_to_slot(card: CardRoot, slot: Slot) -> bool:
	if card.board_presence != null:
		return card.board_presence.enter_slot(slot, card)

	return slot.assign_card(card)


func _release_card_from_source_hand(
	card: CardRoot,
	source_hand: PlayerHandRoot
) -> void:
	if card == null:
		return

	if source_hand != null:
		source_hand.remove_card_from_hand(card)
		source_hand.release_primed_card_for_placement(card)
		source_hand.arrange_cards()
		source_hand.emit_prime_state()

	if controller == null:
		return

	if controller.match_network_root == null:
		return

	if controller.match_network_root.deck_system_root == null:
		return

	var deck_root := controller.match_network_root.deck_system_root

	if deck_root.player_one_hand != null:
		deck_root.player_one_hand.remove_card_from_hand(card)
		deck_root.player_one_hand.arrange_cards()
		deck_root.player_one_hand.emit_prime_state()

	if deck_root.player_two_hand != null:
		deck_root.player_two_hand.remove_card_from_hand(card)
		deck_root.player_two_hand.arrange_cards()
		deck_root.player_two_hand.emit_prime_state()


func _notify_card_placed(
	card: CardRoot,
	slot: Slot,
	owner: SlotRow.SlotOwner
) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if card.mutations == null:
		return

	card.mutations.notify_placed(slot, owner)
