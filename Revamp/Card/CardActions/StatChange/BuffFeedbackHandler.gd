extends Node
class_name BuffedFeedbackHandler

@export var buffed_vfx: BuffedVfx


func play(card: CardRoot) -> void:
	if buffed_vfx != null:
		await buffed_vfx.play(card)
