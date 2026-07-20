extends Node
class_name DebufferFeedbackHandler

@export var debuffer_vfx: DebufferVFX


func play(card: CardRoot = null) -> void:
	if debuffer_vfx != null:
		debuffer_vfx.play(card)


func set_active(value: bool, card: CardRoot = null) -> void:
	if debuffer_vfx != null:
		debuffer_vfx.set_active(value, card)
