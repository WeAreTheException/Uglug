extends Node
class_name BuffFeedbackHandler

signal buff_hidden_moment
signal buff_feedback_finished

@export var debug_enabled: bool = true
@export var debug_key: Key = KEY_F
@export var debug_requires_hover: bool = false

@export var buff_anim: BuffAnim
@export var buff_audio: BuffAudio

var card: Card = null
var is_playing: bool = false


func _ready() -> void:
	card = _find_card_parent()

	if buff_anim == null:
		buff_anim = get_node_or_null("BuffAnim") as BuffAnim

	if buff_audio == null:
		buff_audio = get_node_or_null("BuffAudio") as BuffAudio


func _unhandled_input(event: InputEvent) -> void:
	if not debug_enabled:
		return

	if card == null:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == debug_key:
			if debug_requires_hover and not card.is_hovered:
				return

			play_buff()


func play_buff() -> void:
	if is_playing:
		return

	if card == null:
		return

	is_playing = true

	if buff_audio != null:
		buff_audio.play()

	if buff_anim != null:
		await buff_anim.play(card)

	is_playing = false

	buff_feedback_finished.emit()


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
