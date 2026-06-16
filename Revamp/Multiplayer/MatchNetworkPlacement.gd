extends Node
class_name MatchNetworkPlacement

var root: MatchNetworkRoot = null


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func request_placement(payload: Dictionary) -> void:
	if root == null:
		return

	print(
		"REQUEST PLACEMENT CALLED | HOST: ",
		root.is_host(),
		" payload: ",
		payload
	)

	if root.is_host():
		_process_placement_request(payload)
		return

	GDSync.call_func(root.request_placement, payload)


func receive_confirmed_placement(payload: Dictionary) -> void:
	if root == null:
		return

	if root.placement_controller == null:
		print("CONFIRMED PLACEMENT FAILED: placement_controller missing")
		return

	root.placement_controller.apply_confirmed_placement(payload)


func _process_placement_request(payload: Dictionary) -> void:
	print("PLACEMENT REQUEST RECEIVED: ", payload)

	if not _is_valid_placement_request(payload):
		print("PLACEMENT REQUEST REJECTED")
		return

	_broadcast_confirmed_placement(payload)


func _is_valid_placement_request(payload: Dictionary) -> bool:
	if payload.is_empty():
		print("PLACEMENT VALIDATION FAILED: payload empty")
		return false

	var owner: SlotRow.SlotOwner = payload.get("owner", SlotRow.SlotOwner.PLAYER)
	var card_id: String = payload.get("placed_card_runtime_id", "")
	var slot_owner: SlotRow.SlotOwner = payload.get("target_slot_owner", SlotRow.SlotOwner.PLAYER)
	var slot_index: int = payload.get("target_slot_index", -1)

	var card := root.find_card_anywhere(card_id)

	if card == null:
		print("PLACEMENT VALIDATION FAILED: card missing ", card_id)
		return false

	if root.lookup_network == null:
		print("PLACEMENT VALIDATION FAILED: lookup_network missing")
		return false

	if not root.lookup_network.card_belongs_to_owner_hand(card, owner):
		print("PLACEMENT VALIDATION FAILED: card wrong owner")
		return false

	if root.slots_root == null:
		print("PLACEMENT VALIDATION FAILED: slots_root missing")
		return false

	var slot := root.slots_root.get_slot(slot_owner, slot_index)

	if slot == null:
		print("PLACEMENT VALIDATION FAILED: slot missing")
		return false

	if not slot.is_empty():
		var occupying_card: CardRoot = slot.get_card() as CardRoot

		if occupying_card == null:
			print("PLACEMENT VALIDATION FAILED: slot occupied but card missing")
			return false

		var sacrificed_ids: Array = payload.get("sacrificed_card_runtime_ids", [])

		if not sacrificed_ids.has(occupying_card.get_runtime_id()):
			print("PLACEMENT VALIDATION FAILED: slot occupied")
			return false

	return true


func _broadcast_confirmed_placement(payload: Dictionary) -> void:
	if root.print_debug:
		print("PLACEMENT CONFIRMED: ", payload)

	GDSync.call_func_all(root._receive_confirmed_placement, payload)
