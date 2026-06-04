extends Node
class_name Hand_HoverFocus

var interaction_root: Hand_InteractionRoot = null
var hovered_cards: Array[CardRoot] = []
var focused_card: CardRoot = null


func setup(source_interaction_root: Hand_InteractionRoot) -> void:
	interaction_root = source_interaction_root


func add_hovered_card(card: CardRoot) -> void:
	if card == null:
		return

	if not hovered_cards.has(card):
		hovered_cards.append(card)

	refresh(interaction_root.get_cards())


func remove_hovered_card(card: CardRoot) -> void:
	if hovered_cards.has(card):
		hovered_cards.erase(card)

	if focused_card == card:
		card.set_hover_focused(false)
		focused_card = null

	refresh(interaction_root.get_cards())


func forget_card(card: CardRoot) -> void:
	remove_hovered_card(card)


func refresh(cards: Array[CardRoot]) -> void:
	var top_card := get_top_card(cards)

	if focused_card == top_card:
		return

	if focused_card != null:
		focused_card.set_hover_focused(false)

	focused_card = top_card

	if focused_card != null:
		focused_card.set_hover_focused(true)


func get_top_card(cards: Array[CardRoot]) -> CardRoot:
	for i in range(cards.size() - 1, -1, -1):
		var card := cards[i]

		if hovered_cards.has(card):
			return card

	return null
