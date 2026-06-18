extends Node
class_name MatchAutoDrawHandler

signal auto_draw_started(round_number: int)
signal auto_draw_finished(round_number: int)

@export var match_flow_root: MatchFlowRoot
@export var match_network_root: MatchNetworkRoot

@export var warrior_draw_count_per_owner: int = 1
@export var card_draw_delay: float = 0.12
@export var print_debug: bool = true

var drawn_rounds: Array[int] = []


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state != MatchFlowRoot.MatchState.AUTO_DRAW:
		return

	run_auto_draw()


func run_auto_draw() -> void:
	if match_flow_root == null:
		return

	var round_number: int = match_flow_root.current_round

	if drawn_rounds.has(round_number):
		return

	drawn_rounds.append(round_number)

	if match_network_root == null:
		print("auto draw blocked: match_network_root missing")
		return

	match_flow_root.lock_transition()

	if print_debug:
		print("AUTO DRAW STARTED: ROUND ", round_number)

	auto_draw_started.emit(round_number)

	for i in range(warrior_draw_count_per_owner):
		match_network_root.request_draw(
			SlotRow.SlotOwner.PLAYER,
			DeckSystemRoot.DRAW_PILE_WARRIOR
		)
		await get_tree().create_timer(card_draw_delay).timeout

		match_network_root.request_draw(
			SlotRow.SlotOwner.PLAYER,
			DeckSystemRoot.DRAW_PILE_WORKER
		)
		await get_tree().create_timer(card_draw_delay).timeout

		match_network_root.request_draw(
			SlotRow.SlotOwner.OPPONENT,
			DeckSystemRoot.DRAW_PILE_WARRIOR
		)
		await get_tree().create_timer(card_draw_delay).timeout

		match_network_root.request_draw(
			SlotRow.SlotOwner.OPPONENT,
			DeckSystemRoot.DRAW_PILE_WORKER
		)
		await get_tree().create_timer(card_draw_delay).timeout

	if print_debug:
		print("AUTO DRAW FINISHED: ROUND ", round_number)

	match_flow_root.unlock_transition()
	
	auto_draw_finished.emit(round_number)
