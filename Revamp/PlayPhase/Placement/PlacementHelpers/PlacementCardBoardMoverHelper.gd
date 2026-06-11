extends RefCounted
class_name PlacementCardBoardMoverHelper


func move_card_to_board_layer(card: CardRoot, slot: Slot, board: SlotsRoot) -> void:
	if card == null or slot == null or board == null:
		return

	var parent := board.spawned_card_parent

	if parent == null:
		parent = slot

	var saved_global_transform := card.global_transform

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	parent.add_child(card)
	card.global_transform = saved_global_transform


func snap_card_to_slot(card: CardRoot, slot: Slot, placed_scale: Vector2) -> void:
	if card == null or slot == null:
		return

	card.global_position = slot.get_card_anchor_global_position()
	card.rotation_degrees = 0.0
	card.scale = placed_scale
