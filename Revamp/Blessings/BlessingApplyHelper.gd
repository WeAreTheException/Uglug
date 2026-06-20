extends RefCounted
class_name BlessingApplyHelper


func apply_blessing(card: CardRoot, blessing: Blessing) -> bool:
	if card == null:
		return false

	if blessing == null:
		return false

	if _is_revenant_blessing(blessing):
		card.mark_revenant()
		return card.is_revenant()

	var card_blessings := CardBlessingLookupHelper.new().get_card_blessings(card)

	if card_blessings == null:
		return false

	card_blessings.add_blessing(blessing)
	return true


func _is_revenant_blessing(blessing: Blessing) -> bool:
	if blessing == null:
		return false

	if blessing is RevenantBlessing:
		return true

	var id := blessing.blessing_id.strip_edges().to_snake_case()
	var display_name := blessing.get_display_name().strip_edges().to_snake_case()

	return id == "revenant" or display_name == "revenant"
