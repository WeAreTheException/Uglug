extends Node
class_name CardFeedbackRouter

@export var hurt_profile: CardFeedbackProfile
@export var buffed_profile: CardFeedbackProfile
@export var debuffed_profile: CardFeedbackProfile

@export var sprite_feedback: CardSpriteFeedback
@export var text_feedback: CardTextFeedback
@export var vfx_feedback: CardVfxFeedback
@export var hurt_audio: AudioStreamPlayer2D
@export var motion_feedback: CardMotionFeedback
@export var stat_visual_feedback: CardStatVisualFeedback
@export var stat_color: CardStatColor
@export var buffed_sprite_motion_feedback: CardBuffedSpriteMotionFeedback

@export var test_old_health: int = 1
@export var test_new_health: int = 0

@export var test_old_attack: int = 1
@export var test_buffed_new_attack: int = 2
@export var test_debuffed_new_attack: int = 0

@export var print_debug: bool = true


func play_hurt_feedback() -> void:
	_debug_print("hurt feedback")

	if hurt_profile == null:
		_debug_print("Missing hurt_profile.")
		return

	if hurt_audio != null:
		hurt_audio.stop()
		hurt_audio.play()

	if motion_feedback != null:
		motion_feedback.play_hurt_motion_feedback(hurt_profile)

	if sprite_feedback != null:
		sprite_feedback.play_hurt_sprite_feedback(hurt_profile)

	if vfx_feedback != null:
		vfx_feedback.play_hurt_icon_feedback(hurt_profile)

	if text_feedback != null:
		await text_feedback.play_hurt_health_feedback(
			test_old_health,
			test_new_health,
			hurt_profile
		)


func play_buffed_feedback() -> void:
	_debug_print("buffed feedback")

	if buffed_profile == null:
		_debug_print("Missing buffed_profile.")
		return

	if stat_visual_feedback != null:
		stat_visual_feedback.play_attack_buffed_visual_with_delay()

	if stat_color != null:
		stat_color.apply_attack_idle_color()

	if buffed_sprite_motion_feedback != null:
		buffed_sprite_motion_feedback.play_buffed_sprite_motion()

	if vfx_feedback != null:
		vfx_feedback.play_buffed_attack_vfx(buffed_profile)

	if text_feedback != null:
		await text_feedback.play_buffed_attack_feedback(
			test_old_attack,
			test_buffed_new_attack,
			buffed_profile
		)

	if stat_color != null:
		stat_color.apply_attack_buffed_color()


func play_debuffed_feedback() -> void:
	_debug_print("debuffed feedback")

	var profile := debuffed_profile

	if profile == null:
		profile = buffed_profile

	if profile == null:
		_debug_print("Missing debuffed_profile and buffed_profile fallback.")
		return

	if stat_visual_feedback != null:
		stat_visual_feedback.clear_attack_buffed_visual()

	if stat_color != null:
		stat_color.apply_attack_idle_color()

	if buffed_sprite_motion_feedback != null:
		buffed_sprite_motion_feedback.play_debuffed_sprite_motion()

	if vfx_feedback != null:
		vfx_feedback.play_debuffed_attack_vfx(profile)

	if text_feedback != null:
		await text_feedback.play_debuffed_attack_feedback(
			test_old_attack,
			test_debuffed_new_attack,
			profile
		)

	if stat_color != null:
		stat_color.apply_attack_debuffed_color()


func play_attack_feedback() -> void:
	_debug_print("attack feedback")


func play_mutation_added_feedback() -> void:
	_debug_print("mutation added feedback")


func play_mutation_activated_feedback() -> void:
	_debug_print("mutation activated feedback")


func reset_all_feedback() -> void:
	_debug_print("reset card visuals")

	if buffed_sprite_motion_feedback != null:
		buffed_sprite_motion_feedback.reset_buffed_sprite_motion()

	if stat_visual_feedback != null:
		stat_visual_feedback.reset_stat_visuals()

	if stat_color != null:
		stat_color.reset_all_stat_colors()

	if motion_feedback != null:
		motion_feedback.reset_motion_feedback()

	if sprite_feedback != null:
		sprite_feedback.reset_sprite_feedback()

	if text_feedback != null:
		text_feedback.reset_text_feedback()

	if vfx_feedback != null:
		vfx_feedback.reset_vfx_feedback()


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardFeedbackRouter] ", message)
