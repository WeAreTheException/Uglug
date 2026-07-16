extends Node
class_name DebuffedFeedbackHandler

@export var debuffed_vfx: DebuffedVfx


func play(card: CardRoot) -> void:
	if debuffed_vfx != null:
		await debuffed_vfx.play(card)
