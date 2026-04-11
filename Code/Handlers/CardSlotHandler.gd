extends Node
class_name CardSlotHandler

func try_place(card: Node2D, slot: Node) -> void:
	if slot == null:
		return

	if slot.card_in_slot:
		return

	card.global_position = slot.global_position

	var col := card.get_node_or_null("CollisionShape2D")
	if col:
		col.disabled = true

	slot.card_in_slot = true
