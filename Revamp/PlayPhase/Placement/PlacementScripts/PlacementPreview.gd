extends Node
class_name PlacementPreview

var controller: PlacementController = null
var current_slot: Slot = null
var preview_slots: Array[Slot] = []

var preview_tween: Tween = null
var attack_resolver := PlacementAttackPreviewResolverHelper.new()


func setup(source_controller: PlacementController) -> void:
	controller = source_controller


func show_preview(card: CardRoot, slot: Slot, move_time: float) -> void:
	if card == null or slot == null:
		return

	clear_preview()

	current_slot = slot
	current_slot.show_placement_preview(true)

	_move_card_to_slot(card, slot, move_time)
	_show_attack_preview(card, slot)


func clear_preview() -> void:
	if preview_tween != null:
		preview_tween.kill()
		preview_tween = null

	if current_slot != null:
		current_slot.show_placement_preview(false)

	for slot in preview_slots:
		if slot != null:
			slot.show_attack_preview(false)

	current_slot = null
	preview_slots.clear()


func _show_attack_preview(card: CardRoot, origin_slot: Slot) -> void:
	if controller == null:
		return

	var board := controller.get_slots_root()

	preview_slots = attack_resolver.get_preview_slots(board, card, origin_slot)

	for slot in preview_slots:
		if slot != null:
			slot.show_attack_preview(true)


func _move_card_to_slot(card: CardRoot, slot: Slot, move_time: float) -> void:
	if preview_tween != null:
		preview_tween.kill()

	preview_tween = create_tween()
	preview_tween.set_trans(Tween.TRANS_CUBIC)
	preview_tween.set_ease(Tween.EASE_OUT)

	preview_tween.tween_property(
		card,
		"global_position",
		slot.get_card_anchor_global_position(),
		move_time
	)

	preview_tween.parallel().tween_property(card, "rotation_degrees", 0.0, move_time)
