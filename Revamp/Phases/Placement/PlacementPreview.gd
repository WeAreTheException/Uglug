extends Node
class_name PlacementPreview

var controller: PlacementController = null
var current_slot: Slot = null
var preview_tween: Tween = null

var cached_card: CardRoot = null
var cached_global_position: Vector2 = Vector2.ZERO
var cached_rotation_degrees: float = 0.0
var cached_scale: Vector2 = Vector2.ONE
var has_cached_transform: bool = false


func setup(source_controller: PlacementController) -> void:
	controller = source_controller


func show_preview(card: CardRoot, slot: Slot, move_time: float) -> void:
	if card == null:
		return

	if slot == null:
		return

	_cache_start_transform(card)
	clear_preview()

	current_slot = slot
	current_slot.show_placement_preview(true)

	_move_card_to_slot(card, slot, move_time)


func clear_preview() -> void:
	if current_slot != null:
		current_slot.show_placement_preview(false)

	current_slot = null


func restore_previewed_card(move_time: float) -> void:
	if cached_card == null:
		_clear_cache()
		return

	if not has_cached_transform:
		_clear_cache()
		return

	clear_preview()

	if preview_tween != null:
		preview_tween.kill()

	preview_tween = create_tween()
	preview_tween.set_trans(Tween.TRANS_CUBIC)
	preview_tween.set_ease(Tween.EASE_OUT)

	preview_tween.tween_property(
		cached_card,
		"global_position",
		cached_global_position,
		move_time
	)

	preview_tween.parallel().tween_property(
		cached_card,
		"rotation_degrees",
		cached_rotation_degrees,
		move_time
	)

	preview_tween.parallel().tween_property(
		cached_card,
		"scale",
		cached_scale,
		move_time
	)

	_clear_cache()


func clear_cache() -> void:
	_clear_cache()


func _cache_start_transform(card: CardRoot) -> void:
	if has_cached_transform and cached_card == card:
		return

	cached_card = card
	cached_global_position = card.global_position
	cached_rotation_degrees = card.rotation_degrees
	cached_scale = card.scale
	has_cached_transform = true


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

	preview_tween.parallel().tween_property(
		card,
		"rotation_degrees",
		0.0,
		move_time
	)


func _clear_cache() -> void:
	cached_card = null
	has_cached_transform = false
