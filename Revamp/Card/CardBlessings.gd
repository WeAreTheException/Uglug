extends Node
class_name CardBlessings

signal blessing_added(blessing: Blessing)
signal blessing_removed(blessing: Blessing)
signal blessings_cleared
signal death_handled_by_blessing(blessing: Blessing)

@export var card: CardRoot

var active_blessings: Array[Blessing] = []


func _ready() -> void:
	if card == null:
		card = get_parent() as CardRoot


func add_blessing(source_blessing: Blessing) -> Blessing:
	if source_blessing == null:
		return null

	var blessing := source_blessing.duplicate(true) as Blessing

	if blessing == null:
		return null

	active_blessings.append(blessing)

	if card != null:
		blessing.on_added_to_card(card)

	blessing_added.emit(blessing)
	print("BLESSING ADDED: ", blessing.get_display_name())

	return blessing


func remove_blessing(blessing: Blessing) -> void:
	if blessing == null:
		return

	if not active_blessings.has(blessing):
		return

	active_blessings.erase(blessing)

	if card != null:
		blessing.on_removed_from_card(card)

	blessing_removed.emit(blessing)
	print("BLESSING REMOVED: ", blessing.get_display_name())


func remove_blessing_by_id(blessing_id: String) -> void:
	var blessing := get_blessing_by_id(blessing_id)

	if blessing == null:
		return

	remove_blessing(blessing)


func clear_blessings() -> void:
	for blessing in active_blessings.duplicate():
		remove_blessing(blessing)

	blessings_cleared.emit()


func handle_card_would_die(
	was_hand_sacrifice: bool = false,
	was_discard: bool = false
) -> bool:
	var context := BlessingDeathContext.new()
	context.setup(card, was_hand_sacrifice, was_discard)

	for blessing in active_blessings.duplicate():
		if blessing == null:
			continue

		var handled: bool = blessing.on_card_would_die(context)

		if handled:
			death_handled_by_blessing.emit(blessing)

			if blessing.should_remove_after_death_response():
				remove_blessing(blessing)

			return true

	return false


func has_blessing_id(blessing_id: String) -> bool:
	return get_blessing_by_id(blessing_id) != null


func get_blessing_by_id(blessing_id: String) -> Blessing:
	for blessing in active_blessings:
		if blessing == null:
			continue

		if blessing.blessing_id == blessing_id:
			return blessing

	return null


func get_blessings() -> Array[Blessing]:
	return active_blessings.duplicate()
