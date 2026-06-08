extends RefCounted
class_name CardBalanceLookupHelper


func get_entry(balance_set: CardBalanceSet, card_data: CardData) -> CardBalanceEntry:
	if balance_set == null or card_data == null:
		return null
	return balance_set.get_entry(card_data.get_safe_card_id())
