extends RefCounted
class_name BoardStatAuraRefreshHelper


func refresh_auras(cards: Array[CardRoot]) -> void:
	_clear_all_auras(cards)
	_apply_active_modifier_auras(cards)


func _clear_all_auras(cards: Array[CardRoot]) -> void:
	for card: CardRoot in cards:
		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		card.set_buffer_aura_active(false)
		card.set_debuffer_aura_active(false)


func _apply_active_modifier_auras(cards: Array[CardRoot]) -> void:
	for target_card: CardRoot in cards:
		if target_card == null:
			continue

		if not is_instance_valid(target_card):
			continue

		if target_card.stats == null:
			continue

		for modifier: StatModifier in target_card.stats.modifiers:
			if modifier == null:
				continue

			if not modifier.is_active:
				continue

			var source_card := _get_source_card_from_modifier(modifier)

			if source_card == null:
				continue

			if modifier.amount > 0:
				source_card.set_buffer_aura_active(true)

			if modifier.amount < 0:
				source_card.set_debuffer_aura_active(true)


func _get_source_card_from_modifier(modifier: StatModifier) -> CardRoot:
	if modifier == null:
		return null

	var runtime := modifier.source as MutationRuntime

	if runtime == null:
		return null

	if runtime.owner_card == null:
		return null

	if not is_instance_valid(runtime.owner_card):
		return null

	return runtime.owner_card
