extends RefCounted
class_name HandDragReorderHelper


func update_drag_reorder(
	card: CardRoot,
	current_index: int,
	interaction_root: Hand_InteractionRoot
) -> int:
	if card == null:
		return current_index

	if interaction_root == null:
		return current_index

	var new_index := interaction_root.get_insert_index_from_global_x(card.global_position.x)

	if new_index == current_index:
		return current_index

	interaction_root.move_card_to_index(card, new_index)
	interaction_root.arrange_cards()

	return new_index
