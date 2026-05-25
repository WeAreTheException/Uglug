extends Node
class_name CardSelectionVisualHandler

@export var selected_scale: Vector2 = Vector2(1.15, 1.15)
@export var normal_scale: Vector2 = Vector2(1.0, 1.0)
@export var tween_time: float = 0.12

var card: Node2D = null
var scale_tween: Tween = null


func _ready() -> void:
	card = get_parent() as Node2D


func set_selected(value: bool) -> void:
	if card == null:
		return

	if scale_tween != null:
		scale_tween.kill()

	scale_tween = card.create_tween()

	if value:
		scale_tween.tween_property(card, "scale", selected_scale, tween_time)
	else:
		scale_tween.tween_property(card, "scale", normal_scale, tween_time)
