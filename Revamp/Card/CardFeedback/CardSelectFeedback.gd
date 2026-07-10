extends Node
class_name CardSelectFeedback

@export var target: Node2D
@export var selected_offset: Vector2 = Vector2(0, -28)
@export var tween_time: float = 0.12

var base_position: Vector2 = Vector2.ZERO
var tween: Tween = null


func _ready() -> void:
	if target != null:
		base_position = target.position


func set_selected(value: bool) -> void:
	if target == null:
		return

	if tween != null:
		tween.kill()

	var target_position: Vector2 = base_position

	if value:
		target_position = base_position + selected_offset

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "position", target_position, tween_time)
