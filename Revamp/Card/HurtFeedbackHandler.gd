extends Node
class_name HurtFeedbackHandler

@export var hurt_audio: HurtAudio
@export var hurt_flash: HurtFlash
@export var hurt_sprite: HurtSprite


func play(card: CardRoot) -> void:
	if hurt_audio != null:
		hurt_audio.play()

	if hurt_flash != null:
		hurt_flash.play(card)

	if hurt_sprite != null:
		hurt_sprite.play(card)
