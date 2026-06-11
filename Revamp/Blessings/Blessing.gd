extends Resource
class_name Blessing

@export var blessing_id: String = ""
@export var blessing_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D


func on_added_to_card(_card: CardRoot) -> void:
	pass


func on_removed_from_card(_card: CardRoot) -> void:
	pass


func on_card_would_die(_context: BlessingDeathContext) -> bool:
	return false


func should_remove_after_death_response() -> bool:
	return false


func get_display_name() -> String:
	if blessing_name.is_empty():
		return blessing_id

	return blessing_name
