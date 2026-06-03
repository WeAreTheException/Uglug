extends Node
class_name SacrificeAnimationRunner

@export var visual_target: Node2D

@export var idle_shake_distance: float = 1.0
@export var idle_shake_time: float = 0.08

@export var selected_shake_distance: float = 4.0
@export var selected_shake_time: float = 0.045

@export var random_start_delay_max: float = 0.12

var base_position: Vector2 = Vector2.ZERO
var has_base_values := false

var shake_tween: Tween = null
var delay_tween: Tween = null


func play_idle(card: CardRoot) -> void:
	var target := _get_target(card)

	if target == null:
		return

	_cache_base_values(target)
	_stop_tweens()

	_start_delayed_shake(
		target,
		idle_shake_distance,
		idle_shake_time
	)


func play_selected(card: CardRoot) -> void:
	var target := _get_target(card)

	if target == null:
		return

	_cache_base_values(target)
	_stop_tweens()

	_start_delayed_shake(
		target,
		selected_shake_distance,
		selected_shake_time
	)


func stop_all(card: CardRoot) -> void:
	var target := _get_target(card)

	_stop_tweens()

	if target == null:
		return

	if has_base_values:
		target.position = base_position


func _start_delayed_shake(
	target: Node2D,
	shake_distance: float,
	shake_time: float
) -> void:
	var random_delay := randf_range(0.0, random_start_delay_max)

	delay_tween = create_tween()
	delay_tween.tween_interval(random_delay)
	delay_tween.tween_callback(func():
		_start_shake_loop(target, shake_distance, shake_time)
	)


func _start_shake_loop(
	target: Node2D,
	shake_distance: float,
	shake_time: float
) -> void:
	if target == null:
		return

	shake_tween = create_tween()
	shake_tween.set_loops()
	shake_tween.set_trans(Tween.TRANS_SINE)
	shake_tween.set_ease(Tween.EASE_IN_OUT)

	shake_tween.tween_property(
		target,
		"position:x",
		base_position.x - shake_distance,
		shake_time
	)

	shake_tween.tween_property(
		target,
		"position:x",
		base_position.x + shake_distance,
		shake_time
	)

	shake_tween.tween_property(
		target,
		"position:x",
		base_position.x,
		shake_time
	)


func _get_target(card: CardRoot) -> Node2D:
	if visual_target != null:
		return visual_target

	return card


func _cache_base_values(target: Node2D) -> void:
	if has_base_values:
		return

	base_position = target.position
	has_base_values = true


func _stop_tweens() -> void:
	if delay_tween != null:
		delay_tween.kill()
		delay_tween = null

	if shake_tween != null:
		shake_tween.kill()
		shake_tween = null
