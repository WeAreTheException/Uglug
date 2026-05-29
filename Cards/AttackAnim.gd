extends Node
class_name AttackAnim

@export var use_target_direction: bool = false
@export var attack_direction: Vector2 = Vector2.UP

@export var windup_distance: float = 18.0
@export var attack_distance: float = 200.0

@export var windup_time: float = 0.16
@export var attack_time: float = 0.04
@export var hit_hold_time: float = 0.08
@export var return_time: float = 0.2

@export var windup_scale: Vector2 = Vector2(0.9, 1.1)
@export var attack_scale: Vector2 = Vector2(1.1, 0.9)

@export var windup_rotation_degrees: float = -10.0
@export var attack_rotation_degrees: float = 20.0


func play(card: Card, target: Card = null) -> void:
	if card == null:
		return

	var start_position := card.position
	var start_scale := card.scale
	var start_rotation := card.rotation

	var direction := attack_direction.normalized()

	if use_target_direction and target != null:
		direction = (target.global_position - card.global_position).normalized()

	if direction == Vector2.ZERO:
		direction = Vector2.UP

	var windup_position := start_position - direction * windup_distance
	var attack_position := start_position + direction * attack_distance

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)

	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "position", windup_position, windup_time)
	tween.parallel().tween_property(card, "scale", windup_scale, windup_time)
	tween.parallel().tween_property(card, "rotation", start_rotation + deg_to_rad(windup_rotation_degrees), windup_time)

	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(card, "position", attack_position, attack_time)
	tween.parallel().tween_property(card, "scale", attack_scale, attack_time)
	tween.parallel().tween_property(card, "rotation", start_rotation + deg_to_rad(attack_rotation_degrees), attack_time)

	tween.tween_interval(hit_hold_time)

	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "position", start_position, return_time)
	tween.parallel().tween_property(card, "scale", start_scale, return_time)
	tween.parallel().tween_property(card, "rotation", start_rotation, return_time)

	await tween.finished
