extends Node
class_name PhaseChangeFeedback

signal feedback_finished

@export var phase_manager: PhaseManager
@export var source_phase_label: Label

@export var background_darken: ColorRect
@export var feedback_label: Label

@export var fade_in_time: float = 0.15
@export var hold_time: float = 0.55
@export var fade_out_time: float = 0.25

@export var start_scale: Vector2 = Vector2(0.65, 0.65)
@export var middle_scale: Vector2 = Vector2(1.15, 1.15)
@export var end_scale: Vector2 = Vector2(1.0, 1.0)

@export var start_offset: Vector2 = Vector2(40, 0)
@export var end_offset: Vector2 = Vector2(-20, 0)

@export var darken_alpha: float = 0.65

var tween: Tween
var is_playing_feedback := false
var base_label_position: Vector2


func _ready() -> void:
	if feedback_label != null:
		base_label_position = feedback_label.position

	_hide_feedback()

	if phase_manager != null:
		if not phase_manager.phase_changed.is_connected(play_phase_change):
			phase_manager.phase_changed.connect(play_phase_change)


func play_phase_change(phase_name: String) -> void:
	if source_phase_label != null and source_phase_label.text != "":
		play_feedback_text(source_phase_label.text)
	else:
		play_feedback_text(phase_name)


func play_feedback_text(text_to_show: String) -> void:
	if background_darken == null:
		_finish_feedback()
		return

	if feedback_label == null:
		_finish_feedback()
		return

	if tween != null:
		tween.kill()

	is_playing_feedback = true

	feedback_label.text = text_to_show

	background_darken.visible = true
	feedback_label.visible = true

	background_darken.modulate.a = 0.0
	feedback_label.modulate.a = 0.0

	feedback_label.scale = start_scale
	feedback_label.position = base_label_position + start_offset
	feedback_label.pivot_offset = feedback_label.size * 0.5

	tween = create_tween()

	tween.tween_property(background_darken, "modulate:a", darken_alpha, fade_in_time)
	tween.parallel().tween_property(feedback_label, "modulate:a", 1.0, fade_in_time)
	tween.parallel().tween_property(feedback_label, "scale", middle_scale, fade_in_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		feedback_label,
		"position",
		base_label_position + end_offset,
		fade_in_time + hold_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_interval(hold_time)

	tween.tween_property(background_darken, "modulate:a", 0.0, fade_out_time)
	tween.parallel().tween_property(feedback_label, "modulate:a", 0.0, fade_out_time)
	tween.parallel().tween_property(feedback_label, "scale", end_scale, fade_out_time)

	tween.tween_callback(_finish_feedback)


func _finish_feedback() -> void:
	is_playing_feedback = false
	_hide_feedback()
	feedback_finished.emit()


func _hide_feedback() -> void:
	if background_darken != null:
		background_darken.visible = false
		background_darken.modulate.a = 0.0

	if feedback_label != null:
		feedback_label.visible = false
		feedback_label.modulate.a = 0.0
		feedback_label.scale = start_scale
		feedback_label.position = base_label_position
