extends Node
class_name CardBuffedSpriteMotionFeedback

@export var target_sprite: Node2D

@export_group("Motion")
@export var movement_distance: float = 10.0
@export var move_time: float = 0.12
@export var hold_time: float = 0.06
@export var return_time: float = 0.18

@export_group("Vibration")
@export var vibration_amount: float = 2.0
@export var vibration_frequency: float = 32.0

@export var print_debug: bool = true

var start_position: Vector2 = Vector2.ZERO
var current_offset: Vector2 = Vector2.ZERO

var motion_tween: Tween = null
var is_vibrating: bool = false
var vibration_time: float = 0.0


func _ready() -> void:
	if target_sprite == null:
		_debug_print("Missing target_sprite.")
		return

	start_position = target_sprite.position


func _process(delta: float) -> void:
	if target_sprite == null:
		return

	var vibration_offset := Vector2.ZERO

	if is_vibrating:
		vibration_time += delta
		var wave := sin(vibration_time * vibration_frequency)
		vibration_offset.x = wave * vibration_amount

	target_sprite.position = start_position + current_offset + vibration_offset


func play_buffed_sprite_motion() -> void:
	_play_sprite_motion(-movement_distance)


func play_debuffed_sprite_motion() -> void:
	_play_sprite_motion(movement_distance)


func reset_buffed_sprite_motion() -> void:
	if motion_tween != null:
		motion_tween.kill()
		motion_tween = null

	is_vibrating = false
	vibration_time = 0.0
	current_offset = Vector2.ZERO

	if target_sprite != null:
		target_sprite.position = start_position


func _play_sprite_motion(vertical_distance: float) -> void:
	if target_sprite == null:
		_debug_print("Missing target_sprite.")
		return

	reset_buffed_sprite_motion()

	is_vibrating = true
	vibration_time = 0.0

	motion_tween = create_tween()

	motion_tween.tween_property(
		self,
		"current_offset",
		Vector2(0.0, vertical_distance),
		move_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	motion_tween.tween_interval(hold_time)

	motion_tween.tween_property(
		self,
		"current_offset",
		Vector2.ZERO,
		return_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await motion_tween.finished

	is_vibrating = false
	current_offset = Vector2.ZERO
	target_sprite.position = start_position
	motion_tween = null


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardBuffedSpriteMotionFeedback] ", message)
