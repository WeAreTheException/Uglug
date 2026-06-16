extends Node
class_name MatchNetworkBlessing

var root: MatchNetworkRoot = null


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func request_blessing_confirm(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	if root == null:
		return

	if root.is_host():
		_process_blessing_confirm_request(
			owner,
			target_card_runtime_id,
			blessing_id
		)
		return

	GDSync.call_func(
		root.request_blessing_confirm,
		owner,
		target_card_runtime_id,
		blessing_id
	)


func receive_confirmed_blessing(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	if root == null:
		return

	var card := root.find_card_anywhere(target_card_runtime_id)

	if card == null:
		print("CONFIRMED BLESSING FAILED: card missing ", target_card_runtime_id)
		return

	var blessing := _get_active_blessing_by_id(blessing_id)

	if blessing == null:
		print("CONFIRMED BLESSING FAILED: blessing missing ", blessing_id)
		return

	print("CONFIRMED BLESSING ABOUT TO APPLY: ", blessing_id)

	var applied := BlessingApplyHelper.new().apply_blessing(card, blessing)

	if not applied:
		print("CONFIRMED BLESSING FAILED: apply failed")
		return

	if root.print_debug:
		print(
			"CONFIRMED BLESSING APPLIED: ",
			root.get_owner_name(owner),
			" ",
			blessing.get_display_name(),
			" -> ",
			card.card_name
		)


func _process_blessing_confirm_request(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	var card := root.find_card_anywhere(target_card_runtime_id)

	if card == null:
		print("BLESSING REQUEST REJECTED: card missing ", target_card_runtime_id)
		return

	if root.lookup_network == null:
		print("BLESSING REQUEST REJECTED: lookup_network missing")
		return

	if not root.lookup_network.card_belongs_to_owner_hand(card, owner):
		print("BLESSING REQUEST REJECTED: wrong owner")
		return

	var blessing := _get_active_blessing_by_id(blessing_id)

	if blessing == null:
		print("BLESSING REQUEST REJECTED: blessing missing ", blessing_id)
		return

	_broadcast_confirmed_blessing(owner, target_card_runtime_id, blessing_id)


func _broadcast_confirmed_blessing(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	if root.print_debug:
		print(
			"BLESSING CONFIRMED: ",
			root.get_owner_name(owner),
			" ",
			target_card_runtime_id,
			" ",
			blessing_id
		)

	GDSync.call_func_all(
		root._receive_confirmed_blessing,
		owner,
		target_card_runtime_id,
		blessing_id
	)


func _get_active_blessing_by_id(blessing_id: String) -> Blessing:
	if root.blessing_flow_handler == null:
		return null

	var blessing := root.blessing_flow_handler.get_active_blessing()

	if blessing == null:
		return null

	var clean_id := blessing_id.strip_edges().to_snake_case()
	var active_id := blessing.blessing_id.strip_edges().to_snake_case()

	if active_id != clean_id:
		return null

	return blessing
