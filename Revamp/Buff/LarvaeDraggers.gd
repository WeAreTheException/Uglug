extends Node2D
class_name LarvaeDraggers

@export var larvae_anchor: Node2D
@export var larvae_local_offset: Vector2 = Vector2(-120, 0)

@export var enter_position: Vector2 = Vector2(1920, 500)
@export var center_position: Vector2 = Vector2(910, 500)
@export var exit_position: Vector2 = Vector2(-400, 500)

@export var enter_time: float = 1.5
@export var hold_time: float = 0.5
@export var exit_time: float = 1.0


func play_delivery(larvae: Node2D) -> void:
	global_position = enter_position

	if larvae != null and larvae_anchor != null:
		larvae.reparent(larvae_anchor)
		larvae.position = larvae_local_offset

	var tween := create_tween()
	tween.tween_property(self, "global_position", center_position, enter_time)
	tween.tween_interval(hold_time)

	await tween.finished

	if larvae != null:
		var drop_position := larvae.global_position
		larvae.reparent(get_parent())
		larvae.global_position = drop_position

	var exit_tween := create_tween()
	exit_tween.tween_property(self, "global_position", exit_position, exit_time)

	await exit_tween.finished

	queue_free()
