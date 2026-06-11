extends Blessing
class_name RevenantBlessing


func _init() -> void:
	blessing_id = "revenant"
	blessing_name = "Revenant"
	description = "On death, return to hand. Excluding sacrifice."


func on_card_would_die(context: BlessingDeathContext) -> bool:
	if context == null:
		return false

	if context.was_hand_sacrifice:
		return false

	if context.was_discard:
		return false

	context.was_consumed = true

	if context.card != null:
		print("REVENANT DEATH BLOCKED: ", context.card.name)

	return true


func should_remove_after_death_response() -> bool:
	return true
