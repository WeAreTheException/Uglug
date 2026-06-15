extends RefCounted
class_name BlessingApplyHelper


func apply_blessing(card: CardRoot, blessing: Blessing) -> bool:
	if card == null:
		return false

	if blessing == null:
		return false

	if _is_revenant_blessing(blessing):
		card.mark_revenant()
		return true

	var card_blessings := CardBlessingLookupHelper.new().get_card_blessings(card)

	if card_blessings == null:
		print("Blessing apply blocked: CardBlessings missing on ", card.card_name)
		return false

	card_blessings.add_blessing(blessing)
	return true


func is_matching_blessing(
	blessing: Blessing,
	blessing_id: String
) -> bool:
	if blessing == null:
		return false

	return blessing.blessing_id == blessing_id.strip_edges()


func _is_revenant_blessing(blessing: Blessing) -> bool:
	if blessing == null:
		return false

	if blessing is RevenantBlessing:
		return true

	return blessing.blessing_id == "revenant"
