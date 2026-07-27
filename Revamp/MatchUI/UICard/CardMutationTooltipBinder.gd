extends Node
class_name CardMutationTooltipBinder

@export var mutation_tooltip: MutationToolTip
@export var tooltip_coordinator: MutationTooltipCoordinator
@export var player_hands: Array[PlayerHandRoot] = []

var current_hovered_card: CardRoot = null
var connected_cards: Array[CardRoot] = []


func _ready() -> void:
	for player_hand: PlayerHandRoot in player_hands:
		_connect_hand(player_hand)


func _exit_tree() -> void:
	_clear_current_hovered_card()

	for player_hand: PlayerHandRoot in player_hands:
		_disconnect_hand(player_hand)

	for card: CardRoot in connected_cards.duplicate():
		_disconnect_card(card)

	connected_cards.clear()


func _connect_hand(
	player_hand: PlayerHandRoot
) -> void:
	if player_hand == null:
		return

	if not player_hand.card_added.is_connected(
		_on_card_added
	):
		player_hand.card_added.connect(
			_on_card_added
		)

	if not player_hand.card_removed.is_connected(
		_on_card_removed
	):
		player_hand.card_removed.connect(
			_on_card_removed
		)

	for card: CardRoot in player_hand.get_cards():
		_connect_card(card)


func _disconnect_hand(
	player_hand: PlayerHandRoot
) -> void:
	if player_hand == null:
		return

	if player_hand.card_added.is_connected(
		_on_card_added
	):
		player_hand.card_added.disconnect(
			_on_card_added
		)

	if player_hand.card_removed.is_connected(
		_on_card_removed
	):
		player_hand.card_removed.disconnect(
			_on_card_removed
		)


func _connect_card(card: CardRoot) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if connected_cards.has(card):
		return

	if not card.hovered.is_connected(
		_on_card_hovered
	):
		card.hovered.connect(
			_on_card_hovered
		)

	if not card.unhovered.is_connected(
		_on_card_unhovered
	):
		card.unhovered.connect(
			_on_card_unhovered
		)

	_connect_card_mutations(card)

	connected_cards.append(card)


func _disconnect_card(card: CardRoot) -> void:
	if card == null:
		return

	connected_cards.erase(card)

	if not is_instance_valid(card):
		return

	if card.hovered.is_connected(
		_on_card_hovered
	):
		card.hovered.disconnect(
			_on_card_hovered
		)

	if card.unhovered.is_connected(
		_on_card_unhovered
	):
		card.unhovered.disconnect(
			_on_card_unhovered
		)

	_disconnect_card_mutations(card)


func _connect_card_mutations(
	card: CardRoot
) -> void:
	if card.mutations == null:
		return

	var mutation_callable: Callable = (
		_on_card_mutations_changed.bind(card)
	)

	if not card.mutations.mutations_changed.is_connected(
		mutation_callable
	):
		card.mutations.mutations_changed.connect(
			mutation_callable
		)


func _disconnect_card_mutations(
	card: CardRoot
) -> void:
	if card.mutations == null:
		return

	var mutation_callable: Callable = (
		_on_card_mutations_changed.bind(card)
	)

	if card.mutations.mutations_changed.is_connected(
		mutation_callable
	):
		card.mutations.mutations_changed.disconnect(
			mutation_callable
		)


func _on_card_added(card: CardRoot) -> void:
	_connect_card(card)


func _on_card_removed(card: CardRoot) -> void:
	if current_hovered_card == card:
		_clear_current_hovered_card()

	_disconnect_card(card)


func _on_card_hovered(card: CardRoot) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	current_hovered_card = card
	_show_card(card)


func _on_card_unhovered(card: CardRoot) -> void:
	if current_hovered_card != card:
		return

	_clear_current_hovered_card()


func _on_card_mutations_changed(
	card: CardRoot
) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if current_hovered_card != card:
		return

	_show_card(card)


func _show_card(card: CardRoot) -> void:
	if tooltip_coordinator != null:
		tooltip_coordinator.set_hovered_card(card)
		return

	if mutation_tooltip != null:
		mutation_tooltip.show_card(card)


func _clear_current_hovered_card() -> void:
	var previous_card: CardRoot = current_hovered_card
	current_hovered_card = null

	if tooltip_coordinator != null:
		tooltip_coordinator.clear_hovered_card(
			previous_card
		)
		return

	if mutation_tooltip != null:
		mutation_tooltip.show_default_tooltip()
