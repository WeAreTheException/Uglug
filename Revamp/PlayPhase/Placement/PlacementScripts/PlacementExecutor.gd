extends Node
class_name PlacementExecutor

@export var placed_scale: Vector2 = Vector2.ONE
@export var print_debug: bool = true

var controller: PlacementController = null
var board_mover := PlacementCardBoardMoverHelper.new()
var event_builder := PlacementEventBuilderHelper.new()
var placement_mutation_check := PlacementMutationCheckHelper.new()


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

	_print("EXECUTOR START | card=%s parent=%s" % [
		card.card_name,
		_get_parent_name(card)
	])

	card.setup_board_context(board)

	_release_card_from_source_hand(card, source_hand)

	_print("AFTER RELEASE | card=%s parent=%s source_has_card=%s" % [
		card.card_name,
		_get_parent_name(card),
		str(source_hand.has_card(card) if source_hand != null else false)
	])

	if not _assign_card_to_slot(card, slot):
		_print("ASSIGN FAILED | slot=%s" % slot.name)
		return {}

	_print("AFTER ASSIGN | slot=%s slot_card=%s on_board=%s" % [
		slot.name,
		slot.current_card.card_name if slot.current_card != null else "null",
		str(card.board_presence.is_on_board() if card.board_presence != null else false)
	])

	board_mover.move_card_to_board_layer(card, slot, board)

	_print("AFTER MOVE TO BOARD LAYER | parent=%s" % _get_parent_name(card))

	board_mover.snap_card_to_slot(card, slot, placed_scale)

	card.play_placement_animation()

	_print("AFTER SNAP | pos=%s scale=%s" % [
		str(card.global_position),
		str(card.scale)
	])

	var event: Dictionary = event_builder.build_event(board, card, slot, owner)

	_print("EVENT BUILT | empty=%s event=%s" % [
		str(event.is_empty()),
		str(event)
	])

	_notify_card_placed(card, slot, owner)

	placement_mutation_check.run(card)

	return event


func _assign_card_to_slot(card: CardRoot, slot: Slot) -> bool:
	if card.board_presence != null:
		return card.board_presence.enter_slot(slot, card)

	return slot.assign_card(card)


func _release_card_from_source_hand(
	card: CardRoot,
	source_hand: PlayerHandRoot
) -> void:
	if source_hand == null:
		_print("RELEASE SKIPPED | source_hand=null")
		return

	_print("RELEASE START | source_has_card=%s" % str(source_hand.has_card(card)))

	source_hand.release_primed_card_for_placement(card)

	_print("RELEASE END | source_has_card=%s" % str(source_hand.has_card(card)))


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


func _get_parent_name(card: CardRoot) -> String:
	if card == null:
		return "null"

	if card.get_parent() == null:
		return "null"

	return card.get_parent().name


func _print(message: String) -> void:
	if print_debug:
		print(message)
