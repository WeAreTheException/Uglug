extends Node
class_name AttackAnticipationFeedbackHandler

@export var match_flow_root: MatchFlowRoot
@export var turn_order_state: MatchTurnOrderState
@export var slots_root: SlotsRoot
@export var match_network_root: MatchNetworkRoot

@export var jitter_rotation_degrees: float = 1.5
@export var jitter_time: float = 0.05
@export var print_debug: bool = true

var active_tweens: Dictionary = {}
var current_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var is_active: bool = false


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)

	if not match_flow_root.match_ended.is_connected(_on_match_ended):
		match_flow_root.match_ended.connect(_on_match_ended)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state == MatchFlowRoot.MatchState.ROUND_INTRO:
		start_round_anticipation()
		return

	if state == MatchFlowRoot.MatchState.COMBAT:
		stop_all()
		return

	if state == MatchFlowRoot.MatchState.GAME_END:
		stop_all()


func start_round_anticipation() -> void:
	if turn_order_state == null:
		return

	stop_all()

	current_owner = turn_order_state.attacking_first_owner
	is_active = true

	var visual_owner := _get_visual_owner_for_local_client(current_owner)

	if print_debug:
		print(
			"ATTACK ANTICIPATION STARTED: ",
			_get_owner_name(current_owner),
			" | VISUAL: ",
			_get_owner_name(visual_owner)
		)

	start_for_owner(visual_owner)

func _get_visual_owner_for_local_client(owner: SlotRow.SlotOwner) -> SlotRow.SlotOwner:
	if match_network_root == null:
		return owner

	if match_network_root.is_host():
		return owner

	if owner == SlotRow.SlotOwner.PLAYER:
		return SlotRow.SlotOwner.OPPONENT

	return SlotRow.SlotOwner.PLAYER


func start_for_owner(owner: SlotRow.SlotOwner) -> void:
	stop_for_owner(owner)

	if slots_root == null:
		return

	for slot in slots_root.get_slots_for_owner(owner):
		if slot == null:
			continue

		if slot.current_card == null:
			continue

		_start_card(slot.current_card)


func stop_for_owner(owner: SlotRow.SlotOwner) -> void:
	if slots_root == null:
		return

	for slot in slots_root.get_slots_for_owner(owner):
		if slot == null:
			continue

		if slot.current_card == null:
			continue

		_stop_card(slot.current_card)


func stop_all() -> void:
	var cards := active_tweens.keys()

	for card_object in cards:
		_stop_card_object(card_object)

	if print_debug and is_active:
		print("ATTACK ANTICIPATION STOPPED")

	is_active = false


func _on_match_ended(
	_winner: SlotRow.SlotOwner,
	_final_score: int
) -> void:
	stop_all()


func _start_card(card: CardRoot) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if active_tweens.has(card):
		return

	var step_time: float = max(jitter_time, 0.01)
	var base_rotation: float = card.rotation_degrees

	var tween := create_tween()
	tween.set_loops()

	active_tweens[card] = {
		"tween": tween,
		"base_rotation": base_rotation
	}

	tween.tween_property(
		card,
		"rotation_degrees",
		base_rotation + jitter_rotation_degrees,
		step_time
	)

	tween.tween_property(
		card,
		"rotation_degrees",
		base_rotation - jitter_rotation_degrees,
		step_time
	)

	tween.tween_property(
		card,
		"rotation_degrees",
		base_rotation,
		step_time
	)

	tween.tween_interval(0.01)


func _stop_card(card: CardRoot) -> void:
	_stop_card_object(card)


func _stop_card_object(card_object) -> void:
	if not active_tweens.has(card_object):
		return

	var data: Dictionary = active_tweens[card_object]
	var tween := data["tween"] as Tween

	if tween != null:
		tween.kill()

	if is_instance_valid(card_object):
		var card := card_object as CardRoot

		if card != null:
			var base_rotation: float = data["base_rotation"]
			card.rotation_degrees = base_rotation

	active_tweens.erase(card_object)


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if turn_order_state != null:
		return turn_order_state.get_owner_name(owner)

	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
