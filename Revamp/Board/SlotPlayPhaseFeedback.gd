extends Node
class_name SlotPlayPhaseFeedback

@export var target: Node2D

@export var playable_scale_multiplier: Vector2 = Vector2(1.08, 1.08)
@export var inactive_scale_multiplier: Vector2 = Vector2(0.92, 0.92)

@export var idle_alpha: float = 1.0
@export var playable_alpha: float = 1.0
@export var inactive_alpha: float = 0.55

@export var tween_time: float = 0.12

var slot_feedback: SlotFeedback = null
var tween: Tween = null

var base_scale: Vector2 = Vector2.ONE
var has_base_scale: bool = false


func setup(source_feedback: SlotFeedback) -> void:
	slot_feedback = source_feedback
	_cache_base_values()
	show_idle()


func show_idle() -> void:
	_apply_feedback(base_scale, idle_alpha)


func show_playable() -> void:
	_apply_feedback(
		Vector2(
			base_scale.x * playable_scale_multiplier.x,
			base_scale.y * playable_scale_multiplier.y
		),
		playable_alpha
	)


func show_inactive() -> void:
	_apply_feedback(
		Vector2(
			base_scale.x * inactive_scale_multiplier.x,
			base_scale.y * inactive_scale_multiplier.y
		),
		inactive_alpha
	)


func _cache_base_values() -> void:
	if has_base_scale:
		return

	if target == null:
		return

	base_scale = target.scale
	has_base_scale = true


func _apply_feedback(target_scale: Vector2, target_alpha: float) -> void:
	if target == null:
		return

	_cache_base_values()

	if tween != null:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(target, "scale", target_scale, tween_time)

	if target is CanvasItem:
		tween.parallel().tween_property(
			target,
			"modulate:a",
			target_alpha,
			tween_time
		)
