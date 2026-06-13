extends Node
class_name BuffPhaseAnimationHandler

@export_group("Reward Display")
@export var larvae_reward_scene: PackedScene
@export var larvae_draggers_scene: PackedScene
@export var reward_parent: Node

@export var reward_spawn_position: Vector2 = Vector2(1920, 500)
@export var reward_center_position: Vector2 = Vector2(910, 500)
@export var reward_start_scale: Vector2 = Vector2(0.4, 0.4)
@export var reward_center_scale: Vector2 = Vector2(2, 2)

@export_group("Reward Timing")
@export var reward_move_time: float = 1.5
@export var reward_scale_delay: float = 0.5
@export var reward_scale_time: float = 1.0

@export var print_debug: bool = true

var active_reward_display: LarvaeRewardDisplay = null
var active_draggers: LarvaeDraggers = null
var active_tween: Tween = null


func play_reward_delivery(mutation: Mutation) -> void:
	cleanup()

	if mutation == null:
		print("BUFF ANIMATION BLOCKED: mutation is null")
		return

	await _spawn_and_animate_reward(mutation)


func cleanup() -> void:
	if active_tween != null:
		active_tween.kill()
		active_tween = null

	if active_draggers != null and is_instance_valid(active_draggers):
		active_draggers.queue_free()

	if active_reward_display != null and is_instance_valid(active_reward_display):
		active_reward_display.queue_free()

	active_draggers = null
	active_reward_display = null


func get_active_reward_display() -> LarvaeRewardDisplay:
	return active_reward_display


func _spawn_and_animate_reward(mutation: Mutation) -> void:
	if larvae_reward_scene == null:
		print("BUFF ANIMATION WARNING: larvae_reward_scene missing")
		return

	var reward := larvae_reward_scene.instantiate() as LarvaeRewardDisplay
	if reward == null:
		print("BUFF ANIMATION WARNING: larvae_reward_scene is not LarvaeRewardDisplay")
		return

	active_reward_display = reward

	var parent := reward_parent
	if parent == null:
		parent = get_tree().current_scene

	parent.add_child(reward)

	reward.global_position = reward_spawn_position
	reward.scale = reward_start_scale
	reward.setup_from_mutation(mutation)

	var draggers := _spawn_draggers(parent)

	if draggers != null:
		active_draggers = draggers
		await draggers.play_delivery(reward)
	else:
		reward.global_position = reward_center_position

	await _scale_reward(reward)

	if print_debug:
		print("BUFF REWARD DISPLAY READY")


func _spawn_draggers(parent: Node) -> LarvaeDraggers:
	if larvae_draggers_scene == null:
		print("BUFF ANIMATION WARNING: larvae_draggers_scene missing")
		return null

	var draggers := larvae_draggers_scene.instantiate() as LarvaeDraggers
	if draggers == null:
		print("BUFF ANIMATION WARNING: larvae_draggers_scene is not LarvaeDraggers")
		return null

	parent.add_child(draggers)
	return draggers


func _scale_reward(reward: LarvaeRewardDisplay) -> void:
	if reward == null:
		return

	active_tween = create_tween()
	active_tween.tween_interval(reward_scale_delay)
	active_tween.tween_property(
		reward,
		"scale",
		reward_center_scale,
		reward_scale_time
	)

	await active_tween.finished
