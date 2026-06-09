extends Node
class_name AttackFeedback

signal impact_reached

@export var profile: AttackFeedbackProfile
@export var target: Node2D
var root: CardFeedbackRoot = null
var original_z_index := 0

func setup_feedback_root(source_root: CardFeedbackRoot) -> void:
	root = source_root

func play(context: AttackContext) -> void:
	if target == null or context == null or profile == null:
		return
	var difference := context.target_slot.slot_index - context.attacker_slot.slot_index
	var direction := AttackDirectionHelper.get_direction(difference)
	if context.attacker_owner == SlotRow.SlotOwner.OPPONENT:
		direction.y *= -1.0
	await _play_motion(direction, difference, context.attack_animation_layer)

func _play_motion(direction: Vector2, difference: int, layer: Node2D) -> void:
	var parent := target.get_parent()
	var index := target.get_index()
	var global_transform := target.global_transform
	original_z_index = target.z_index
	if layer != null:
		target.reparent(layer)
		target.global_transform = global_transform
	target.z_index = profile.attack_z_index
	var start_pos := target.position
	var start_scale := target.scale
	var start_rot := target.rotation
	var side := AttackDirectionHelper.get_rotation_side(difference)
	var windup_pos := start_pos - direction * _windup_distance(difference)
	var attack_pos := start_pos + direction * _attack_distance(difference)
	var tween := create_tween()
	tween.tween_property(target, "position", windup_pos, profile.windup_time)
	tween.parallel().tween_property(target, "scale", profile.windup_scale, profile.windup_time)
	tween.parallel().tween_property(target, "rotation", start_rot + deg_to_rad(profile.windup_rotation_degrees * side), profile.windup_time)
	tween.tween_property(target, "position", attack_pos, profile.attack_time)
	tween.parallel().tween_property(target, "scale", profile.attack_scale, profile.attack_time)
	tween.parallel().tween_property(target, "rotation", start_rot + deg_to_rad(profile.attack_rotation_degrees * side), profile.attack_time)
	tween.tween_callback(func() -> void: impact_reached.emit())
	tween.tween_interval(profile.hit_hold_time)
	tween.tween_property(target, "position", start_pos, profile.return_time)
	tween.parallel().tween_property(target, "scale", start_scale, profile.return_time)
	tween.parallel().tween_property(target, "rotation", start_rot, profile.return_time)
	await tween.finished
	_restore_parent(parent, index)
	target.z_index = original_z_index

func _restore_parent(parent: Node, index: int) -> void:
	if parent != null and target.get_parent() != parent:
		var t := target.global_transform
		target.reparent(parent)
		parent.move_child(target, index)
		target.global_transform = t

func _windup_distance(difference: int) -> float:
	return profile.forward_windup_distance if abs(difference) == 0 else profile.diagonal_windup_distance

func _attack_distance(difference: int) -> float:
	return profile.forward_attack_distance if abs(difference) == 0 else profile.diagonal_attack_distance
