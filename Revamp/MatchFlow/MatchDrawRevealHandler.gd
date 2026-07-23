extends Node
class_name MatchDrawRevealHandler

@export var match_flow_root: MatchFlowRoot
@export var match_network_root: MatchNetworkRoot
@export var print_debug: bool = true

var covered_cards: Array[CardRoot] = []


func _ready() -> void:
	if match_flow_root != null:
		if not match_flow_root.match_state_changed.is_connected(
			_on_match_state_changed
		):
			match_flow_root.match_state_changed.connect(
				_on_match_state_changed
			)

	call_deferred("_connect_draw_network")


func _connect_draw_network() -> void:
	if match_network_root == null:
		print("DRAW REVEAL BLOCKED: MatchNetworkRoot missing")
		return

	if match_network_root.draw_network == null:
		print("DRAW REVEAL BLOCKED: MatchNetworkDraw missing")
		return

	if not match_network_root.draw_network.confirmed_draw_applied.is_connected(
		_on_confirmed_draw_applied
	):
		match_network_root.draw_network.confirmed_draw_applied.connect(
			_on_confirmed_draw_applied
		)


func _on_confirmed_draw_applied(
	_owner: SlotRow.SlotOwner,
	card: CardRoot,
	pile_type: String
) -> void:
	if pile_type != DeckSystemRoot.DRAW_PILE_WARRIOR:
		return

	if card == null or not is_instance_valid(card):
		return

	call_deferred("_cover_card_after_setup", card)


func _cover_card_after_setup(card: CardRoot) -> void:
	if card == null or not is_instance_valid(card):
		return

	if match_flow_root == null:
		return

	if (
		match_flow_root.current_state
		!= MatchFlowRoot.MatchState.AUTO_DRAW
	):
		card.set_hidden_for_draw(false)
		return

	card.set_hidden_for_draw(true)

	if not covered_cards.has(card):
		covered_cards.append(card)

	if print_debug:
		print("DRAW WARRIOR COVERED: ", card.card_name)


func _on_match_state_changed(
	state: MatchFlowRoot.MatchState
) -> void:
	if state == MatchFlowRoot.MatchState.AUTO_DRAW:
		_clear_invalid_cards()
		return

	_reveal_all_cards()


func _reveal_all_cards() -> void:
	for card: CardRoot in covered_cards:
		if card == null or not is_instance_valid(card):
			continue

		card.set_hidden_for_draw(false)

		if print_debug:
			print("DRAW WARRIOR REVEALED: ", card.card_name)

	covered_cards.clear()


func _clear_invalid_cards() -> void:
	var valid_cards: Array[CardRoot] = []

	for card: CardRoot in covered_cards:
		if card != null and is_instance_valid(card):
			valid_cards.append(card)

	covered_cards = valid_cards
