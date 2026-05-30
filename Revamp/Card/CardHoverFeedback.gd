extends Node
class_name CardHoverFeedback

@export var target: Node2D
@export var hover_scale: Vector2 = Vector2(1.05, 1.05)
@export var tween_time: float = 0.12

var base_scale: Vector2 = Vector2.ONE
var tween: Tween = null
var is_enabled := true


func _ready() -> void:
	if target != null:
		base_scale = target.scale


func set_enabled(value: bool) -> void:
	is_enabled = value

	if not is_enabled:
		play_unhover()


func play_hover() -> void:
	if not is_enabled:
		return

	if target == null:
		return

	_tween_scale(hover_scale)


func play_unhover() -> void:
	if target == null:
		return

	_tween_scale(base_scale)


func _tween_scale(target_scale: Vector2) -> void:
	if tween != null:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "scale", target_scale, tween_time)
