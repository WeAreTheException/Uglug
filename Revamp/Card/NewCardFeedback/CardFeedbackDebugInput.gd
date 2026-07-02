extends Node
class_name CardFeedbackDebugInput

@export var feedback_router: CardFeedbackRouter

@export var hurt_key: Key = KEY_H
@export var buffed_key: Key = KEY_B
@export var debuffed_key: Key = KEY_D
@export var attack_key: Key = KEY_A
@export var mutation_added_key: Key = KEY_M
@export var mutation_activated_key: Key = KEY_N
@export var reset_key: Key = KEY_R

@export var print_debug: bool = true


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed:
		return

	if key_event.echo:
		return

	if feedback_router == null:
		_debug_print("Missing feedback_router.")
		return

	match key_event.keycode:
		hurt_key:
			feedback_router.play_hurt_feedback()
		buffed_key:
			feedback_router.play_buffed_feedback()
		debuffed_key:
			feedback_router.play_debuffed_feedback()
		attack_key:
			feedback_router.play_attack_feedback()
		mutation_added_key:
			feedback_router.play_mutation_added_feedback()
		mutation_activated_key:
			feedback_router.play_mutation_activated_feedback()
		reset_key:
			feedback_router.reset_all_feedback()


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardFeedbackDebugInput] ", message)
