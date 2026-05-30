extends Node
class_name CardSelectFeedback

@export var target: Node2D
@export var shadow: CanvasItem

@export var selected_offset: Vector2 = Vector2(0, -28)
@export var selected_scale: Vector2 = Vector2(1.08, 1.08)
@export var shadow_alpha: float = 0.45
@export var tween_time: float = 0.12

var base_position: Vector2 = Vector2.ZERO
var base_scale: Vector2 = Vector2.ONE
var tween: Tween = null


func _ready() -> void:
	if target != null:
		base_position = target.position
		base_scale = target.scale

	if shadow != null:
		shadow.visible = true
		shadow.modulate.a = 0.0


func set_selected(value: bool) -> void:
	if target == null:
		return

	if tween != null:
		tween.kill()

	var final_position := base_position
	var final_scale := base_scale
	var final_shadow_alpha := 0.0

	if value:
		final_position = base_position + selected_offset
		final_scale = selected_scale
		final_shadow_alpha = shadow_alpha

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(target, "position", final_position, tween_time)
	tween.parallel().tween_property(target, "scale", final_scale, tween_time)

	if shadow != null:
		tween.parallel().tween_property(shadow, "modulate:a", final_shadow_alpha, tween_time)
