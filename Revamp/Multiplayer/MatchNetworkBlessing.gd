extends Node
class_name MatchNetworkBlessing

@export var phase_timer: MatchPhaseTimer
@export var selection_state: BlessingSelectionState

var root: MatchNetworkRoot = null
var confirmed_owners: Dictionary = {}


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root
	_connect_timer()


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


func _connect_timer() -> void:
	if phase_timer == null:
		return

	if not phase_timer.timer_finished.is_connected(_on_timer_finished):
		phase_timer.timer_finished.connect(_on_timer_finished)


func _process_blessing_confirm_request(
	owner: SlotRow.SlotOwner,
	target_card_runtime_id: String,
	blessing_id: String
) -> void:
	if confirmed_owners.has(owner):
		print("BLESSING REQUEST REJECTED: owner already confirmed")
		return

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

	confirmed_owners[owner] = true

	_broadcast_confirmed_blessing(owner, target_card_runtime_id, blessing_id)
	_try_finish_if_all_confirmed()


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


func _try_finish_if_all_confirmed() -> void:
	if confirmed_owners.has(SlotRow.SlotOwner.PLAYER) and confirmed_owners.has(SlotRow.SlotOwner.OPPONENT):
		_finish_blessing_phase()


func _on_timer_finished(state: MatchFlowRoot.MatchState) -> void:
	if root == null:
		return

	if not root.is_host():
		return

	if state != MatchFlowRoot.MatchState.BLESSING:
		return

	_resolve_unconfirmed_owner(SlotRow.SlotOwner.PLAYER)
	_resolve_unconfirmed_owner(SlotRow.SlotOwner.OPPONENT)
	_finish_blessing_phase()


func _resolve_unconfirmed_owner(owner: SlotRow.SlotOwner) -> void:
	if confirmed_owners.has(owner):
		return

	if root.blessing_flow_handler == null:
		return

	var blessing := root.blessing_flow_handler.get_active_blessing()

	if blessing == null:
		return

	var card := _get_fallback_card(owner)

	if card == null:
		print("BLESSING TIMEOUT FAILED: no fallback card for ", root.get_owner_name(owner))
		return

	confirmed_owners[owner] = true

	_broadcast_confirmed_blessing(
		owner,
		card.get_runtime_id(),
		blessing.blessing_id.to_snake_case()
	)


func _get_fallback_card(owner: SlotRow.SlotOwner) -> CardRoot:
	if selection_state != null:
		var selected := selection_state.get_selected_card(owner)

		if selected != null:
			return selected

	if root == null:
		return null

	if root.deck_system_root == null:
		return null

	var hand := root.deck_system_root.get_hand_for_owner(owner)

	if hand == null:
		return null

	var cards := hand.get_cards()

	if cards.is_empty():
		return null

	return cards.pick_random()


func _finish_blessing_phase() -> void:
	if root == null:
		return

	GDSync.call_func_all(root._receive_blessing_flow_finished)


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

func receive_blessing_flow_finished() -> void:
	confirmed_owners.clear()

	if root == null:
		return

	if root.blessing_flow_handler != null:
		root.blessing_flow_handler.force_finish_blessing_flow()
