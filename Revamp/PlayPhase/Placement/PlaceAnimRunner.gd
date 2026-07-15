extends Node
class_name PlacementAnimationRunner

@export var animation_player: AnimationPlayer
@export var animation_name: String = "placement"
@export var print_debug: bool = true


func play_placement_animation() -> void:
	if animation_player == null:
		if print_debug:
			print("PLACEMENT ANIM BLOCKED: animation_player null")
		return

	if not animation_player.has_animation(animation_name):
		if print_debug:
			print("PLACEMENT ANIM BLOCKED: missing animation ", animation_name)
		return

	if print_debug:
		print("PLACEMENT ANIM PLAY: ", animation_name)

	animation_player.stop()
	animation_player.play(animation_name)
