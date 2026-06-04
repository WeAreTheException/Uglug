extends RefCounted
class_name HandSpawnerStoreHelper

var cards: Array[CardRoot] = []


func add_card(card: CardRoot) -> bool:
	if card == null:
		return false

	if cards.has(card):
		return false

	cards.append(card)
	return true


func remove_card(card: CardRoot) -> bool:
	if not cards.has(card):
		return false

	cards.erase(card)
	return true


func move_card_to_index(card: CardRoot, index: int) -> bool:
	if not cards.has(card):
		return false

	cards.erase(card)

	var safe_index := clampi(index, 0, cards.size())
	cards.insert(safe_index, card)

	return true


func sort_cards(sorter: Callable) -> void:
	cards.sort_custom(sorter)


func get_cards() -> Array[CardRoot]:
	return cards.duplicate()


func has_card(card: CardRoot) -> bool:
	return cards.has(card)


func size() -> int:
	return cards.size()
