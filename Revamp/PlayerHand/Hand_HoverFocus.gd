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

	refresh(_get_hand_cards())


func remove_hovered_card(card: CardRoot) -> void:
	hovered_cards.erase(card)

	if focused_card == card:
		card.set_hover_focused(false)
		focused_card = null

	refresh(_get_hand_cards())


func forget_card(card: CardRoot) -> void:
	hovered_cards.erase(card)

	if focused_card == card:
		card.set_hover_focused(false)
		focused_card = null


func refresh(hand_cards: Array[CardRoot]) -> void:
	var new_focus := get_top_card(hand_cards)

	if focused_card == new_focus:
		return

	if focused_card != null:
		focused_card.set_hover_focused(false)

	focused_card = new_focus

	if focused_card != null:
		focused_card.set_hover_focused(true)


func get_top_card(hand_cards: Array[CardRoot]) -> CardRoot:
	for i in range(hand_cards.size() - 1, -1, -1):
		var card := hand_cards[i]

		if card == null:
			continue

		if hovered_cards.has(card):
			return card

	return null


func _get_hand_cards() -> Array[CardRoot]:
	if interaction_root == null:
		return []

	return interaction_root.get_cards()
