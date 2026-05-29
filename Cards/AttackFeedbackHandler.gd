extends Node
class_name AttackFeedbackHandler

signal attack_feedback_finished

@export var attack_anim: AttackAnim
@export var attack_audio: AttackAudio

var card: Card = null
var is_playing: bool = false


func _ready() -> void:
	card = _find_card_parent()

	if attack_anim == null:
		attack_anim = get_node_or_null("AttackAnim") as AttackAnim

	if attack_audio == null:
		attack_audio = get_node_or_null("AttackAudio") as AttackAudio


func play_attack(target: Card = null) -> void:
	if is_playing:
		return
	if card == null:
		return

	is_playing = true

	if attack_audio != null:
		attack_audio.play()

	if attack_anim != null:
		await attack_anim.play(card, target)

	is_playing = false
	attack_feedback_finished.emit()


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
