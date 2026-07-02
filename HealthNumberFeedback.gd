extends Node2D

@export var enabled: bool = true

@export_group("Soft Float")
@export var vertical_float_height: float = 6.0
@export var vertical_float_time: float = 2.5

@export var horizontal_drift_amount: float = 2.0
@export var horizontal_drift_time: float = 4.0

@export var rotation_amount_degrees: float = 0.8
@export var rotation_time: float = 5.0

@export_group("Breathing Scale")
@export var breathing_scale_amount: float = 0.03
@export var breathing_scale_time: float = 2.5

@export_group("Punch Test")
@export var punch_key: Key = KEY_H
@export var squash_scale: Vector2 = Vector2(1.35, 0.55)
@export var stretch_scale: Vector2 = Vector2(0.8, 1.3)
@export var neutral_punch_scale: Vector2 = Vector2.ONE

@export var squash_time: float = 0.06
@export var stretch_time: float = 0.08
@export var return_time: float = 0.10

var start_position: Vector2
var start_rotation: float
var start_scale: Vector2
var time_passed: float = 0.0

var punch_scale: Vector2 = Vector2.ONE
var punch_tween: Tween = null


func _ready() -> void:
	start_position = position
	start_rotation = rotation
	start_scale = scale


func _process(delta: float) -> void:
	if not enabled:
		position = start_position
		rotation = start_rotation
		scale = start_scale * punch_scale
		return

	time_passed += delta

	var vertical_wave := sin((time_passed / vertical_float_time) * TAU)
	var horizontal_wave := sin((time_passed / horizontal_drift_time) * TAU)
	var rotation_wave := sin((time_passed / rotation_time) * TAU)
	var breathing_wave := sin((time_passed / breathing_scale_time) * TAU)

	var y_offset := vertical_wave * vertical_float_height
	var x_offset := horizontal_wave * horizontal_drift_amount
	var rotation_offset := deg_to_rad(rotation_wave * rotation_amount_degrees)
	var scale_multiplier := 1.0 + (breathing_wave * breathing_scale_amount)

	position = start_position + Vector2(x_offset, y_offset)
	rotation = start_rotation + rotation_offset
	scale = start_scale * scale_multiplier * punch_scale


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey

		if key_event.pressed and not key_event.echo and key_event.keycode == punch_key:
			play_punch()


func play_punch() -> void:
	if punch_tween != null:
		punch_tween.kill()

	punch_scale = neutral_punch_scale

	punch_tween = create_tween()
	punch_tween.set_trans(Tween.TRANS_BACK)
	punch_tween.set_ease(Tween.EASE_OUT)

	punch_tween.tween_property(self, "punch_scale", squash_scale, squash_time)
	punch_tween.tween_property(self, "punch_scale", stretch_scale, stretch_time)
	punch_tween.tween_property(self, "punch_scale", neutral_punch_scale, return_time)
