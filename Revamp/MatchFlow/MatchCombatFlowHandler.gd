extends Node
class_name MatchCombatFlowHandler

signal combat_flow_started(first_owner: SlotRow.SlotOwner)
signal combat_flow_finished

@export var match_flow_root: MatchFlowRoot
@export var turn_order_state: MatchTurnOrderState
@export var anticipation_feedback: AttackAnticipationFeedbackHandler
@export var match_network_root: MatchNetworkRoot
@export var slots_root: SlotsRoot

@export var auto_advance_on_combat_finished: bool = true
@export var use_attack_anticipation: bool = true
@export var print_debug: bool = true

var is_running: bool = false


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(
		_on_match_state_changed
	):
		match_flow_root.match_state_changed.connect(
			_on_match_state_changed
		)


func _on_match_state_changed(
	state: MatchFlowRoot.MatchState
) -> void:
	if state != MatchFlowRoot.MatchState.COMBAT:
		return

	if (
		match_network_root != null
		and not match_network_root.is_host()
	):
		if print_debug:
			print(
				"CLIENT COMBAT FLOW SKIPPED: ",
				"waiting for host attack events"
			)

		return

	begin_combat_flow()


func begin_combat_flow() -> void:
	if is_running:
		return

	var attack_order_handler := _get_attack_order_handler()

	if attack_order_handler == null:
		print(
			"combat flow blocked: ",
			"attack_order_handler missing"
		)
		return

	is_running = true

	if match_flow_root != null:
		match_flow_root.lock_transition()

	var first_owner: SlotRow.SlotOwner = (
		_get_attacking_first_owner()
	)

	var second_owner: SlotRow.SlotOwner = (
		_get_opposing_owner(first_owner)
	)

	if print_debug:
		print(
			"COMBAT FLOW STARTED: ",
			_get_owner_name(first_owner),
			" FIRST"
		)

	combat_flow_started.emit(first_owner)

	var attack_entries := (
		attack_order_handler
		.get_global_attack_entries_in_order(
			first_owner,
			second_owner
		)
	)

	await _run_global_attack_order(
		attack_entries
	)

	_stop_all_anticipation()

	_finalize_score_after_combat()

	if print_debug:
		print("COMBAT FLOW FINISHED")

	combat_flow_finished.emit()

	if match_flow_root != null:
		match_flow_root.unlock_transition()

	is_running = false

	_try_auto_advance_after_combat()


func _run_global_attack_order(
	entries: Array[Dictionary]
) -> void:
	var attack_order_handler := _get_attack_order_handler()

	if attack_order_handler == null:
		return

	var has_active_owner := false
	var active_owner := SlotRow.SlotOwner.PLAYER

	for entry in entries:
		if not entry.has("owner"):
			continue

		var owner: SlotRow.SlotOwner = entry["owner"]

		var card := (
			attack_order_handler
			.get_valid_card_from_global_entry(entry)
		)

		if card == null:
			continue

		if (
			not has_active_owner
			or active_owner != owner
		):
			if has_active_owner:
				_stop_anticipation(active_owner)

			active_owner = owner
			has_active_owner = true

			if print_debug:
				print(
					"COMBAT ATTACK OWNER: ",
					_get_owner_name(owner),
					" | CARD: ",
					card.card_name,
					" | PRIORITY: ",
					entry.get("priority", 0)
				)

			_start_anticipation(owner)

		if match_network_root == null:
			continue

		if match_network_root.attack_network == null:
			continue

		var payload := (
			match_network_root
			.attack_network
			.build_attack_payload(
				card,
				owner
			)
		)

		if payload.is_empty():
			continue

		if (
			not match_network_root
			.attack_network
			.is_valid_attack_payload(
				payload,
				owner
			)
		):
			continue

		await (
			match_network_root
			.attack_network
			.run_confirmed_attack(payload)
		)

	if has_active_owner:
		_stop_anticipation(active_owner)


func _run_owner_attack_order(
	owner: SlotRow.SlotOwner
) -> void:
	var attack_order_handler := _get_attack_order_handler()

	if attack_order_handler == null:
		return

	if print_debug:
		print(
			"COMBAT ATTACK ORDER: ",
			_get_owner_name(owner)
		)

	_start_anticipation(owner)

	var cards := (
		attack_order_handler
		.get_attack_cards_in_order(owner)
	)

	for card in cards:
		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if match_network_root == null:
			continue

		if match_network_root.attack_network == null:
			continue

		var payload := (
			match_network_root
			.attack_network
			.build_attack_payload(
				card,
				owner
			)
		)

		if payload.is_empty():
			continue

		if (
			not match_network_root
			.attack_network
			.is_valid_attack_payload(
				payload,
				owner
			)
		):
			continue

		await (
			match_network_root
			.attack_network
			.run_confirmed_attack(payload)
		)

	_stop_anticipation(owner)


func _finalize_score_after_combat() -> void:
	if match_network_root == null:
		return

	if not match_network_root.is_host():
		return

	match_network_root.finalize_score_after_combat()


func _start_anticipation(
	owner: SlotRow.SlotOwner
) -> void:
	if not use_attack_anticipation:
		return

	if anticipation_feedback == null:
		return

	anticipation_feedback.start_for_owner(owner)


func _stop_anticipation(
	owner: SlotRow.SlotOwner
) -> void:
	if anticipation_feedback == null:
		return

	anticipation_feedback.stop_for_owner(owner)


func _stop_all_anticipation() -> void:
	if anticipation_feedback == null:
		return

	anticipation_feedback.stop_all()


func _is_game_ended() -> bool:
	if match_flow_root == null:
		return false

	return (
		match_flow_root.current_state
		== MatchFlowRoot.MatchState.GAME_END
	)


func _has_finalized_winner() -> bool:
	if match_network_root == null:
		return false

	if match_network_root.match_score_state == null:
		return false

	return (
		match_network_root
		.match_score_state
		.has_winner
	)


func _get_attack_order_handler() -> AttackOrderHandler:
	if slots_root == null:
		return null

	return slots_root.attack_order_handler


func _get_attacking_first_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	return turn_order_state.attacking_first_owner


func _get_opposing_owner(
	owner: SlotRow.SlotOwner
) -> SlotRow.SlotOwner:
	if turn_order_state != null:
		return turn_order_state.get_opposing_owner(owner)

	if owner == SlotRow.SlotOwner.PLAYER:
		return SlotRow.SlotOwner.OPPONENT

	return SlotRow.SlotOwner.PLAYER


func _get_owner_name(
	owner: SlotRow.SlotOwner
) -> String:
	if turn_order_state != null:
		return turn_order_state.get_owner_name(owner)

	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"


func _try_auto_advance_after_combat() -> void:
	if not auto_advance_on_combat_finished:
		return

	if match_network_root == null:
		return

	if not match_network_root.is_host():
		return

	if _has_finalized_winner():
		if print_debug:
			print(
				"COMBAT COMPLETE: WINNER FINALIZED, ",
				"SKIPPING NORMAL MATCH ADVANCE"
			)

		return

	if match_flow_root == null:
		return

	if (
		match_flow_root.current_state
		!= MatchFlowRoot.MatchState.COMBAT
	):
		return

	if print_debug:
		print(
			"COMBAT COMPLETE: ",
			"REQUESTING MATCH ADVANCE"
		)

	match_network_root.request_advance_match_state()
