extends Node
class_name AttackFeedbackHandler

signal attack_feedback_finished

@export var attack_anim: AttackAnim

@export var attack_close_right_anim: AttackAnim
@export var attack_far_right_anim: AttackAnim
@export var attack_furthest_right_anim: AttackAnim

@export var attack_close_left_anim: AttackAnim
@export var attack_far_left_anim: AttackAnim
@export var attack_furthest_left_anim: AttackAnim

@export var attack_audio: AttackAudio
@export var attack_screen_shake: AttackScreenShake

var card: Card = null
var is_playing: bool = false


func _ready() -> void:
	card = _find_card_parent()

	if attack_anim == null:
		attack_anim = get_node_or_null("AttackAnim") as AttackAnim

	if attack_close_right_anim == null:
		attack_close_right_anim = get_node_or_null("AttackCloseRightAnim") as AttackAnim

	if attack_far_right_anim == null:
		attack_far_right_anim = get_node_or_null("AttackFarRightAnim") as AttackAnim

	if attack_furthest_right_anim == null:
		attack_furthest_right_anim = get_node_or_null("AttackFurthestRightAnim") as AttackAnim

	if attack_close_left_anim == null:
		attack_close_left_anim = get_node_or_null("AttackCloseLeftAnim") as AttackAnim

	if attack_far_left_anim == null:
		attack_far_left_anim = get_node_or_null("AttackFarLeftAnim") as AttackAnim

	if attack_furthest_left_anim == null:
		attack_furthest_left_anim = get_node_or_null("AttackFurthestLeftAnim") as AttackAnim

	if attack_audio == null:
		attack_audio = get_node_or_null("AttackAudio") as AttackAudio

	if attack_screen_shake == null:
		attack_screen_shake = get_node_or_null("AttackScreenShake") as AttackScreenShake


func _unhandled_input(event: InputEvent) -> void:
	if card == null:
		return

	if is_playing:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Z:
				await _play_debug_anim(attack_furthest_left_anim)

			KEY_X:
				await _play_debug_anim(attack_far_left_anim)

			KEY_C:
				await _play_debug_anim(attack_close_left_anim)

			KEY_V:
				await _play_debug_anim(attack_close_right_anim)

			KEY_B:
				await _play_debug_anim(attack_far_right_anim)

			KEY_N:
				await _play_debug_anim(attack_furthest_right_anim)


func _play_debug_anim(anim: AttackAnim) -> void:
	if anim == null:
		return

	is_playing = true

	if attack_audio != null:
		attack_audio.play()

	if attack_screen_shake != null:
		attack_screen_shake.play()

	await anim.play(card)

	is_playing = false


func play_attack(target: Card = null) -> void:
	if is_playing:
		return

	if card == null:
		return

	is_playing = true

	if attack_audio != null:
		attack_audio.play()

	if attack_screen_shake != null:
		attack_screen_shake.play()

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
