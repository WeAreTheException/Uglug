extends Node
class_name CardFeedbackRouter

@export var hurt_profile: CardFeedbackProfile
@export var sprite_feedback: CardSpriteFeedback
@export var text_feedback: CardTextFeedback

@export var test_old_health: int = 1
@export var test_new_health: int = 0

@export var print_debug: bool = true


func play_hurt_feedback() -> void:
	_debug_print("hurt feedback")

	if hurt_profile == null:
		_debug_print("Missing hurt_profile.")
		return

	if sprite_feedback != null:
		sprite_feedback.play_hurt_sprite_feedback(hurt_profile)

	if text_feedback != null:
		await text_feedback.play_hurt_health_feedback(
			test_old_health,
			test_new_health,
			hurt_profile
		)


func play_buffed_feedback() -> void:
	_debug_print("buffed feedback")


func play_debuffed_feedback() -> void:
	_debug_print("debuffed feedback")


func play_attack_feedback() -> void:
	_debug_print("attack feedback")


func play_mutation_added_feedback() -> void:
	_debug_print("mutation added feedback")


func play_mutation_activated_feedback() -> void:
	_debug_print("mutation activated feedback")


func reset_all_feedback() -> void:
	_debug_print("reset card visuals")

	if sprite_feedback != null:
		sprite_feedback.reset_sprite_feedback()

	if text_feedback != null:
		text_feedback.reset_text_feedback()


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardFeedbackRouter] ", message)
