extends Node
class_name PlacementAnimationRunner

@export var animation_player: AnimationPlayer
@export var animation_name: String = "placement"


func play_placement_animation() -> float:
	if animation_player == null:
		return 0.0

	if not animation_player.has_animation(animation_name):
		return 0.0

	var animation: Animation = animation_player.get_animation(animation_name)

	if animation == null:
		return 0.0

	animation_player.stop()
	animation_player.play(animation_name)

	return animation.length
