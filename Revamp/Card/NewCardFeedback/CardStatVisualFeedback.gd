extends Node
class_name CardStatVisualFeedback

@export_group("Attack Shader Stripe")
@export var attack_stripe_label: RichTextLabel

@export var show_attack_stripe_when_buffed: bool = true
@export var attack_buffed_shader_delay: float = 0.65

@export var print_debug: bool = true

var attack_shader_delay_tween: Tween = null


func _ready() -> void:
	clear_attack_buffed_visual()


func play_attack_buffed_visual_with_delay() -> void:
	clear_attack_buffed_visual()

	if not show_attack_stripe_when_buffed:
		return

	if attack_stripe_label == null:
		return

	if attack_shader_delay_tween != null:
		attack_shader_delay_tween.kill()
		attack_shader_delay_tween = null

	attack_shader_delay_tween = create_tween()
	attack_shader_delay_tween.tween_interval(attack_buffed_shader_delay)
	attack_shader_delay_tween.tween_callback(apply_attack_buffed_visual)


func apply_attack_buffed_visual() -> void:
	if attack_stripe_label == null:
		return

	attack_stripe_label.visible = true
	attack_stripe_label.modulate = Color.WHITE


func clear_attack_buffed_visual() -> void:
	if attack_shader_delay_tween != null:
		attack_shader_delay_tween.kill()
		attack_shader_delay_tween = null

	if attack_stripe_label == null:
		return

	attack_stripe_label.visible = false
	attack_stripe_label.modulate = Color.WHITE


func reset_stat_visuals() -> void:
	clear_attack_buffed_visual()


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardStatVisualFeedback] ", message)
