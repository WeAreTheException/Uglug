extends Node
class_name AttackFeedbackHandler

signal attack_feedback_finished

@export var move_distance: float = 45.0
@export var move_time: float = 0.25
@export var return_time: float = 0.25
@export var squash_scale: Vector2 = Vector2(1.08, 0.94)

@export var attack_sfx: AudioStream
@export var volume_db: float = 0.0

var card: Card = null
var is_playing: bool = false
var audio_player: AudioStreamPlayer


func _ready() -> void:
	card = _find_card_parent()

	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = volume_db


func play_attack(target: Card = null) -> void:
	if is_playing:
		return

	if card == null:
		return

	is_playing = true

	var start_position := card.position
	var start_scale := card.scale

	var direction := Vector2.UP

	if target != null:
		direction = (target.global_position - card.global_position).normalized()

	var attack_position := start_position + (direction * move_distance)

	if attack_sfx != null:
		audio_player.stream = attack_sfx
		audio_player.play()

	var tween := create_tween()

	tween.tween_property(card, "position", attack_position, move_time)
	tween.parallel().tween_property(card, "scale", squash_scale, move_time)

	tween.tween_property(card, "position", start_position, return_time)
	tween.parallel().tween_property(card, "scale", start_scale, return_time)

	await tween.finished

	is_playing = false

	attack_feedback_finished.emit()


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
