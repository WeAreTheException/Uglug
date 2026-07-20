extends Node
class_name BufferFeedbackHandler

@export var buffer_vfx: BufferVFX


func play(card: CardRoot = null) -> void:
	if buffer_vfx != null:
		buffer_vfx.play(card)


func set_active(value: bool, card: CardRoot = null) -> void:
	if buffer_vfx != null:
		buffer_vfx.set_active(value, card)
