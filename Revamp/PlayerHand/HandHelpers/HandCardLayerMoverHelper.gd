extends RefCounted
class_name HandCardLayerMoverHelper


func move_to_layer(card: CardRoot, target_layer: Node2D) -> void:
	if card == null:
		return

	if target_layer == null:
		return

	var saved_global_transform := card.global_transform

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	target_layer.add_child(card)
	card.global_transform = saved_global_transform
