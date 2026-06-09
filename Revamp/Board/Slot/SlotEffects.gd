extends Node
class_name SlotEffects

signal effects_changed
signal effect_added(effect: Resource)
signal effect_removed(effect: Resource)

var slot: Slot = null
var active_effects: Array[Resource] = []


func setup(source_slot: Slot) -> void:
	slot = source_slot


func add_effect(effect: Resource) -> void:
	if effect == null:
		return

	active_effects.append(effect)

	if effect.has_method("on_added_to_slot"):
		effect.on_added_to_slot(slot)

	effect_added.emit(effect)
	effects_changed.emit()


func remove_effect(effect: Resource) -> void:
	if effect == null:
		return

	if not active_effects.has(effect):
		return

	if effect.has_method("on_removed_from_slot"):
		effect.on_removed_from_slot(slot)

	active_effects.erase(effect)

	effect_removed.emit(effect)
	effects_changed.emit()


func clear_effects() -> void:
	var effects := active_effects.duplicate()

	for effect in effects:
		remove_effect(effect)


func get_effects() -> Array[Resource]:
	return active_effects.duplicate()


func has_effects() -> bool:
	return not active_effects.is_empty()


func on_card_entered(card: CardRoot) -> void:
	if card == null:
		return

	for effect in active_effects.duplicate():
		if effect == null:
			continue

		if effect.has_method("on_card_entered_slot"):
			effect.on_card_entered_slot(slot, card)


func on_card_left(card: CardRoot) -> void:
	if card == null:
		return

	for effect in active_effects.duplicate():
		if effect == null:
			continue

		if effect.has_method("on_card_left_slot"):
			effect.on_card_left_slot(slot, card)


func refresh_effects() -> void:
	for effect in active_effects.duplicate():
		if effect == null:
			continue

		if effect.has_method("refresh_slot_effect"):
			effect.refresh_slot_effect(slot)
