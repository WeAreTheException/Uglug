extends Node
class_name DeathFeedbackHandler

signal death_feedback_finished

@export var death_anim: DeathAnim
@export var death_audio: DeathAudio

var card: Card = null
var is_playing: bool = false


func _ready() -> void:
	card = _find_card_parent()

	if death_anim == null:
		death_anim = get_node_or_null("DeathAnim") as DeathAnim

	if death_audio == null:
		death_audio = get_node_or_null("DeathAudio") as DeathAudio


func play_death() -> void:
	if is_playing:
		return

	is_playing = true

	if death_audio != null:
		death_audio.play_detached()

	if death_anim != null and card != null:
		await death_anim.play(card)

	is_playing = false
	death_feedback_finished.emit()


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
