extends Resource
class_name DeckEntry

@export var card_data: CardData
@export var amount: int = 1


func is_valid() -> bool:
	return card_data != null and amount > 0


func get_card_id() -> String:
	if card_data == null:
		return ""
	return card_data.get_safe_card_id()
