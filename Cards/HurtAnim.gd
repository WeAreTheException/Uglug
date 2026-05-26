extends Node
class_name HurtFeedbackHandler

@export var shake_distance: float = 10.0
@export var shake_time: float = 0.04
@export var flash_time: float = 0.05

@export var hurt_sfx: AudioStream
@export var volume_db: float = 0.0

var card: Card = null
var is_playing: bool = false
var audio_player: AudioStreamPlayer


func _ready() -> void:
	card = _find_card_parent()

	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = volume_db


func play_hurt() -> void:
	if card == null:
		return
	if is_playing:
		return

	is_playing = true
	_play_sfx(hurt_sfx)

	var start_pos := card.position
	var sprite: Sprite2D = card.get_main_sprite()

	if sprite != null:
		sprite.modulate = Color(1, 0.5, 0.5, 1)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(card, "position", start_pos + Vector2(-shake_distance, 0), shake_time)
	tween.tween_property(card, "position", start_pos + Vector2(shake_distance, 0), shake_time)
	tween.tween_property(card, "position", start_pos, shake_time)

	await tween.finished

	if sprite != null:
		await get_tree().create_timer(flash_time).timeout
		sprite.modulate = Color(1, 1, 1, 1)

	is_playing = false


func _play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return

	audio_player.stream = stream
	audio_player.play()


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
