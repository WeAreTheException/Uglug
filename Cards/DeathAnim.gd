extends Node
class_name DeathFeedbackHandler

@export var rise_amount: float = 20.0
@export var death_time: float = 0.18
@export var end_scale: Vector2 = Vector2(0.7, 0.7)

@export var death_sfx: AudioStream
@export var volume_db: float = 0.0
@export var sfx_bus_name: String = "SFX"


var card: Card = null
var is_playing: bool = false
var audio_player: AudioStreamPlayer


func _ready() -> void:
	card = _find_card_parent()

	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = volume_db


func play_death() -> void:
	if card == null:
		return
	if is_playing:
		return

	is_playing = true
	_play_sfx(death_sfx)

	var start_pos := card.position
	var sprite: Sprite2D = card.get_main_sprite()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(card, "position", start_pos + Vector2(0, -rise_amount), death_time)
	tween.parallel().tween_property(card, "scale", end_scale, death_time)

	if sprite != null:
		tween.parallel().tween_property(sprite, "modulate", Color(1, 1, 1, 0), death_time)

	await tween.finished
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
