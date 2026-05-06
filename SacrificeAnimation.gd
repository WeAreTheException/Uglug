extends Node
class_name SacrificeAnimation

func show_sacrifice_selected(card: Card) -> void:
	if card == null:
		return

	card.set_selected(true)

func show_sacrifice_unselected(card: Card) -> void:
	if card == null:
		return

	card.set_selected(false)

func show_sacrifice_hint(card: Card) -> void:
	if card == null:
		return

	card.start_sacrifice_hint()

func hide_sacrifice_hint(card: Card) -> void:
	if card == null:
		return

	card.stop_sacrifice_hint()
