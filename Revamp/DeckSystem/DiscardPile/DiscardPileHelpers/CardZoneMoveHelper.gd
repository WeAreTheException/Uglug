extends RefCounted
class_name CardZoneMoveHelper


func detach_card(card: CardRoot) -> void:
	if card != null and card.get_parent() != null:
		card.get_parent().remove_child(card)
