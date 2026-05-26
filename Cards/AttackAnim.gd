extends Node
class_name AttackFeedbackHandler

@export var move_distance: float = 45.0
@export var move_time: float = 0.08
@export var return_time: float = 0.10
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
	if card == null:
		return
	if is_playing:
		return

	is_playing = true
	_play_sfx(attack_sfx)

	var start_pos := card.position
	var start_scale := card.scale

	var dir := Vector2.RIGHT

	if target != null and is_instance_valid(target):
		dir = (target.global_position - card.global_position).normalized()
	else:
		if card.card_owner == Card.Owner.PLAYER:
			dir = Vector2.UP
		else:
			dir = Vector2.DOWN

	var hit_pos := start_pos + (dir * move_distance)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "position", hit_pos, move_time)
	tween.parallel().tween_property(card, "scale", squash_scale, move_time)
	tween.tween_property(card, "position", start_pos, return_time)
	tween.parallel().tween_property(card, "scale", start_scale, return_time)

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
