extends Node
class_name AttackAnim

@export var windup_distance: float = 18.0
@export var attack_distance: float = 55.0

@export var windup_time: float = 0.12
@export var attack_time: float = 0.10
@export var hit_hold_time: float = 0.08
@export var return_time: float = 0.18

@export var windup_scale: Vector2 = Vector2(0.96, 1.06)
@export var attack_scale: Vector2 = Vector2(1.10, 0.92)

@export var windup_rotation_degrees: float = -6.0
@export var attack_rotation_degrees: float = 4.0


func play(card: Card, target: Card = null) -> void:
	if card == null:
		return

	var start_position := card.position
	var start_scale := card.scale
	var start_rotation := card.rotation

	var direction := Vector2.UP

	if target != null:
		direction = (target.global_position - card.global_position).normalized()

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
