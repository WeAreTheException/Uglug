extends Node
class_name Hand_HoverFocus

var interaction_root: Hand_InteractionRoot = null
var hovered_cards: Array[CardRoot] = []
var focused_card: CardRoot = null


func setup(
	source_interaction_root: Hand_InteractionRoot
) -> void:
	interaction_root = source_interaction_root


func add_hovered_card(
	card: CardRoot
) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	_prune_invalid_references()

	if not hovered_cards.has(card):
		hovered_cards.append(card)

	_refresh_from_root()


func remove_hovered_card(
	card: CardRoot
) -> void:
	_prune_invalid_references()

	if card != null and is_instance_valid(card):
		if hovered_cards.has(card):
			hovered_cards.erase(card)

		if focused_card == card:
			card.set_hover_focused(false)
			focused_card = null

	_refresh_from_root()


func forget_card(
	card: CardRoot
) -> void:
	remove_hovered_card(card)


func refresh(
	cards: Array[CardRoot]
) -> void:
	_prune_invalid_references()

	var top_card: CardRoot = get_top_card(cards)

	if focused_card == top_card:
		return

	if (
		focused_card != null
		and is_instance_valid(focused_card)
	):
		focused_card.set_hover_focused(false)

	focused_card = top_card

	if (
		focused_card != null
		and is_instance_valid(focused_card)
	):
		focused_card.set_hover_focused(true)


func get_top_card(
	cards: Array[CardRoot]
) -> CardRoot:
	_prune_invalid_references()

	for i: int in range(
		cards.size() - 1,
		-1,
		-1
	):
		var card: CardRoot = cards[i]

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if hovered_cards.has(card):
			return card

	return null


func _refresh_from_root() -> void:
	if interaction_root == null:
		return

	refresh(
		interaction_root.get_cards()
	)


func _prune_invalid_references() -> void:
	for i: int in range(
		hovered_cards.size() - 1,
		-1,
		-1
	):
		var card: CardRoot = hovered_cards[i]

		if card == null:
			hovered_cards.remove_at(i)
			continue

		if not is_instance_valid(card):
			hovered_cards.remove_at(i)

	if (
		focused_card != null
		and not is_instance_valid(focused_card)
	):
		focused_card = null
