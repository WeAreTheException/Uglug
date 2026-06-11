extends RefCounted
class_name CardBlessingLookupHelper


func get_card_blessings(card: CardRoot) -> CardBlessings:
	if card == null:
		return null

	for child in card.get_children():
		var card_blessings := child as CardBlessings

		if card_blessings != null:
			return card_blessings

	return null
