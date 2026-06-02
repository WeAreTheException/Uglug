extends Node
class_name AttackAnimationRunner

@export var animated_target: Node2D

@export_category("Forward")
@export var forward_windup_distance: float = 18.0
@export var forward_attack_distance: float = 200.0
@export var forward_windup_rotation_degrees: float = -10.0
@export var forward_attack_rotation_degrees: float = 20.0

@export_category("Diagonal Close")
@export var diagonal_close_windup_distance: float = 18.0
@export var diagonal_close_attack_distance: float = 180.0
@export var diagonal_close_windup_rotation_degrees: float = -8.0
@export var diagonal_close_attack_rotation_degrees: float = 18.0

@export_category("Diagonal Far")
@export var diagonal_far_windup_distance: float = 20.0
@export var diagonal_far_attack_distance: float = 220.0
@export var diagonal_far_windup_rotation_degrees: float = -12.0
@export var diagonal_far_attack_rotation_degrees: float = 24.0

@export_category("Diagonal Furthest")
@export var diagonal_furthest_windup_distance: float = 22.0
@export var diagonal_furthest_attack_distance: float = 260.0
@export var diagonal_furthest_windup_rotation_degrees: float = -15.0
@export var diagonal_furthest_attack_rotation_degrees: float = 30.0

@export_category("Shared Timing")
@export var windup_time: float = 0.16
@export var attack_time: float = 0.04
@export var hit_hold_time: float = 0.08
@export var return_time: float = 0.2

@export_category("Shared Scale")
@export var windup_scale: Vector2 = Vector2(0.9, 1.1)
@export var attack_scale: Vector2 = Vector2(1.1, 0.9)

@export var raise_z_index_during_attack: bool = true
@export var attack_z_index: int = 100


func play_attack(context: AttackContext) -> void:
	if animated_target == null:
		return

	if context == null:
		return

	if context.attacker_slot == null:
		return

	if context.target_slot == null:
		return

	var difference: int = context.target_slot.slot_index - context.attacker_slot.slot_index
	var direction: Vector2 = _get_direction_from_difference(difference)

	if context.attacker_owner == SlotRow.SlotOwner.OPPONENT:
		direction.y *= -1.0

	await _play_motion(
	direction,
	_get_windup_distance(difference),
	_get_attack_distance(difference),
	_get_windup_rotation(difference, context.attacker_owner),
	_get_attack_rotation(difference, context.attacker_owner),
	context.attack_animation_layer
)


func _play_motion(
	direction: Vector2,
	windup_distance: float,
	attack_distance: float,
	windup_rotation_degrees: float,
	attack_rotation_degrees: float,
	attack_animation_layer: Node2D = null
) -> void:
	var original_parent: Node = animated_target.get_parent()
	var original_index: int = animated_target.get_index()
	var original_global_transform: Transform2D = animated_target.global_transform

	if attack_animation_layer != null:
		animated_target.reparent(attack_animation_layer)
		animated_target.global_transform = original_global_transform

	var start_position: Vector2 = animated_target.position
	var start_scale: Vector2 = animated_target.scale
	var start_rotation: float = animated_target.rotation

	var windup_position: Vector2 = start_position - direction * windup_distance
	var attack_position: Vector2 = start_position + direction * attack_distance

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)

	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_target, "position", windup_position, windup_time)
	tween.parallel().tween_property(animated_target, "scale", windup_scale, windup_time)
	tween.parallel().tween_property(animated_target, "rotation", start_rotation + deg_to_rad(windup_rotation_degrees), windup_time)

	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(animated_target, "position", attack_position, attack_time)
	tween.parallel().tween_property(animated_target, "scale", attack_scale, attack_time)
	tween.parallel().tween_property(animated_target, "rotation", start_rotation + deg_to_rad(attack_rotation_degrees), attack_time)

	tween.tween_interval(hit_hold_time)

	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_target, "position", start_position, return_time)
	tween.parallel().tween_property(animated_target, "scale", start_scale, return_time)
	tween.parallel().tween_property(animated_target, "rotation", start_rotation, return_time)

	await tween.finished

	if attack_animation_layer != null and original_parent != null:
		var return_global_transform: Transform2D = animated_target.global_transform
		animated_target.reparent(original_parent)
		original_parent.move_child(animated_target, original_index)
		animated_target.global_transform = return_global_transform

	animated_target.position = Vector2.ZERO
	animated_target.scale = start_scale
	animated_target.rotation = start_rotation


func _get_direction_from_difference(difference: int) -> Vector2:
	match difference:
		-3:
			return Vector2(-1, -0.35).normalized()
		-2:
			return Vector2(-1, -0.55).normalized()
		-1:
			return Vector2(-1, -0.85).normalized()
		0:
			return Vector2.UP
		1:
			return Vector2(1, -0.85).normalized()
		2:
			return Vector2(1, -0.55).normalized()
		3:
			return Vector2(1, -0.35).normalized()

	return Vector2.UP


func _get_windup_distance(difference: int) -> float:
	match abs(difference):
		0:
			return forward_windup_distance
		1:
			return diagonal_close_windup_distance
		2:
			return diagonal_far_windup_distance
		3:
			return diagonal_furthest_windup_distance

	return forward_windup_distance


func _get_attack_distance(difference: int) -> float:
	match abs(difference):
		0:
			return forward_attack_distance
		1:
			return diagonal_close_attack_distance
		2:
			return diagonal_far_attack_distance
		3:
			return diagonal_furthest_attack_distance

	return forward_attack_distance


func _get_windup_rotation(difference: int, attacker_owner: SlotRow.SlotOwner) -> float:
	var side := _get_rotation_side(difference, attacker_owner)

	match abs(difference):
		0:
			return forward_windup_rotation_degrees * side
		1:
			return diagonal_close_windup_rotation_degrees * side
		2:
			return diagonal_far_windup_rotation_degrees * side
		3:
			return diagonal_furthest_windup_rotation_degrees * side

	return forward_windup_rotation_degrees * side


func _get_attack_rotation(difference: int, attacker_owner: SlotRow.SlotOwner) -> float:
	var side := _get_rotation_side(difference, attacker_owner)

	match abs(difference):
		0:
			return forward_attack_rotation_degrees * side
		1:
			return diagonal_close_attack_rotation_degrees * side
		2:
			return diagonal_far_attack_rotation_degrees * side
		3:
			return diagonal_furthest_attack_rotation_degrees * side

	return forward_attack_rotation_degrees * side


func _get_rotation_side(difference: int, _attacker_owner: SlotRow.SlotOwner) -> float:
	var side: float = signf(float(difference))

	if side == 0.0:
		side = 1.0

	return side
