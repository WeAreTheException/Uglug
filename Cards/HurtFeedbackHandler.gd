extends Node
class_name HurtFeedbackHandler

@export var hurt_anim: HurtAnim
@export var hurt_audio: HurtAudio
@export var hurt_flash: HurtFlash
@export var hurt_sprite: HurtSprite

var card: Card = null
var is_playing: bool = false


func _ready() -> void:
	card = _find_card_parent()

	if hurt_anim == null:
		hurt_anim = get_node_or_null("HurtAnim") as HurtAnim

	if hurt_audio == null:
		hurt_audio = get_node_or_null("HurtAudio") as HurtAudio

	if hurt_flash == null:
		hurt_flash = get_node_or_null("HurtFlash") as HurtFlash

	if hurt_sprite == null:
		hurt_sprite = get_node_or_null("HurtSprite") as HurtSprite


func play_hurt() -> void:
	if card == null:
		return
	if is_playing:
		return

	is_playing = true

	if hurt_audio != null:
		hurt_audio.play()

	if hurt_flash != null:
		hurt_flash.play(card)

	if hurt_sprite != null:
		hurt_sprite.play(card)

	if hurt_anim != null:
		await hurt_anim.play(card)

	is_playing = false


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
