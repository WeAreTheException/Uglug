extends Resource
class_name CardBalanceSet

@export var balance_id: String = ""
@export var entries: Array[CardBalanceEntry] = []


func get_entry(card_id: String) -> CardBalanceEntry:
	for entry in entries:
		if entry != null and entry.card_id == card_id:
			return entry
	return null
