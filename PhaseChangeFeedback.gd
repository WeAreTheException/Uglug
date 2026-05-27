extends Node2D
class_name PhaseChangeFeedback

@export var phase_manager: PhaseManager

@export var background_darken: ColorRect
@export var phase_label: Label

@export var fade_in_time: float = 0.15
@export var hold_time: float = 0.55
@export var fade_out_time: float = 0.25

@export var start_scale: Vector2 = Vector2(0.65, 0.65)
@export var middle_scale: Vector2 = Vector2(1.15, 1.15)
@export var end_scale: Vector2 = Vector2(1.0, 1.0)

@export var darken_alpha: float = 0.65

var tween: Tween


func _ready() -> void:
	if background_darken != null:
		background_darken.visible = false
		background_darken.modulate.a = 0.0

	if phase_label != null:
		phase_label.visible = false
		phase_label.modulate.a = 0.0
		phase_label.scale = start_scale
		phase_label.pivot_offset = phase_label.size * 0.5

	if phase_manager != null:
		if not phase_manager.phase_changed.is_connected(play_phase_change):
			phase_manager.phase_changed.connect(play_phase_change)


func play_phase_change(phase_name: String) -> void:
	if phase_label == null or background_darken == null:
		return

	if tween != null:
		tween.kill()

	phase_label.text = phase_name
	phase_label.visible = true
	background_darken.visible = true

	phase_label.modulate.a = 0.0
	background_darken.modulate.a = 0.0
	phase_label.scale = start_scale
	phase_label.pivot_offset = phase_label.size * 0.5

	tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(background_darken, "modulate:a", darken_alpha, fade_in_time)
	tween.tween_property(phase_label, "modulate:a", 1.0, fade_in_time)
	tween.tween_property(phase_label, "scale", middle_scale, fade_in_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.chain()
	tween.tween_interval(hold_time)

	tween.chain()
	tween.set_parallel(true)
	tween.tween_property(background_darken, "modulate:a", 0.0, fade_out_time)
	tween.tween_property(phase_label, "modulate:a", 0.0, fade_out_time)
	tween.tween_property(phase_label, "scale", end_scale, fade_out_time)

	tween.chain()
	tween.tween_callback(_hide_feedback)


func _hide_feedback() -> void:
	if background_darken != null:
		background_darken.visible = false

	if phase_label != null:
		phase_label.visible = false
