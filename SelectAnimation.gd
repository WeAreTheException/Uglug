extends Node
class_name SelectAnimation

func show_card_selected(card: Card) -> void:
	if card == null:
		return

	card.set_selected(true)

func show_card_unselected(card: Card) -> void:
	if card == null:
		return

	card.set_selected(false)

func clear_pending_visual(pending_play_card: Card) -> void:
	if pending_play_card == null:
		return

	show_card_unselected(pending_play_card)

func clear_sacrifice_visuals(sacrifice_handler: SacrificeHandler) -> void:
	if sacrifice_handler == null:
		return

	sacrifice_handler.clear_selected_sacrifice_visuals()
