extends RefCounted
class_name BlessingApplyHelper


func apply_blessing(card: CardRoot, blessing: Blessing) -> bool:
	print("BLESSING APPLY DEBUG card null: ", card == null)
	print("BLESSING APPLY DEBUG blessing null: ", blessing == null)

	if card != null:
		print("BLESSING APPLY DEBUG card: ", card.card_name)
		print("BLESSING APPLY DEBUG runtime_state null: ", card.runtime_state == null)

	if blessing != null:
		print("BLESSING APPLY DEBUG class: ", blessing.get_class())
		print("BLESSING APPLY DEBUG id: ", blessing.blessing_id)
		print("BLESSING APPLY DEBUG name: ", blessing.get_display_name())
		print("BLESSING APPLY DEBUG is RevenantBlessing: ", blessing is RevenantBlessing)
		print("BLESSING APPLY DEBUG revenant check: ", _is_revenant_blessing(blessing))

	if card == null:
		return false

	if blessing == null:
		return false

	if _is_revenant_blessing(blessing):
		card.mark_revenant()
		print("BLESSING APPLY DEBUG after mark revenant: ", card.is_revenant())
		return card.is_revenant()

	var card_blessings := CardBlessingLookupHelper.new().get_card_blessings(card)

	print("BLESSING APPLY DEBUG card_blessings null: ", card_blessings == null)

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
