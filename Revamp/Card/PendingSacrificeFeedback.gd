extends Node
class_name PendingSacrificeFeedback

@export var target: CanvasItem
@export var pending_alpha: float = 0.25
@export var tween_time: float = 0.08

var sacrifice: Sacrifice = null
var base_modulate: Color = Color.WHITE
var has_base_modulate: bool = false
var tween: Tween = null


func setup(source_sacrifice: Sacrifice) -> void:
	sacrifice = source_sacrifice


func set_pending(card: CardRoot, value: bool) -> void:
	var target_item := _get_target(card)

	if target_item == null:
		return

	_cache_base_modulate(target_item)

	if value:
		_tween_modulate(target_item, Color(
			base_modulate.r,
			base_modulate.g,
			base_modulate.b,
			pending_alpha
		))
	else:
		_tween_modulate(target_item, base_modulate)


func _get_target(card: CardRoot) -> CanvasItem:
	if target != null:
		return target

	return card


func _cache_base_modulate(target_item: CanvasItem) -> void:
	if has_base_modulate:
		return

	base_modulate = target_item.modulate
	has_base_modulate = true


func _tween_modulate(target_item: CanvasItem, color: Color) -> void:
	if tween != null:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target_item, "modulate", color, tween_time)
