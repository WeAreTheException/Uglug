extends RefCounted
class_name CardBlessingLookupHelper


func get_card_blessings(card: CardRoot) -> CardBlessings:
	if card == null:
		return null

	return _find_card_blessings_recursive(card)


func _find_card_blessings_recursive(node: Node) -> CardBlessings:
	if node == null:
		return null

	var card_blessings := node as CardBlessings

	if card_blessings != null:
		return card_blessings

	for child in node.get_children():
		var found := _find_card_blessings_recursive(child)

		if found != null:
			return found

	return null
