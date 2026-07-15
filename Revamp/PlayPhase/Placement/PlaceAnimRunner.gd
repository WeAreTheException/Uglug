extends Node
class_name PlacementAnimationRunner

@export var animation_player: AnimationPlayer
@export var animation_name: String = "placement"


func play_placement_animation() -> void:
	if animation_player == null:
		return

	if not animation_player.has_animation(animation_name):
		return

	animation_player.stop()
	animation_player.play(animation_name)
