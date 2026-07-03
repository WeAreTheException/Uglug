extends Node
class_name CardVfxFeedback

@export_group("Hurt Icon")
@export var hurt_icon: CanvasItem

@export_group("Buffed Attack VFX")
@export var buff_attack_vfx_sprite: CanvasItem

@export var print_debug: bool = true

var hurt_icon_start_position: Vector2 = Vector2.ZERO
var hurt_icon_start_scale: Vector2 = Vector2.ONE
var hurt_icon_start_modulate: Color = Color.WHITE
var hurt_icon_start_visible: bool = false

var buff_attack_vfx_start_position: Vector2 = Vector2.ZERO
var buff_attack_vfx_start_scale: Vector2 = Vector2.ONE
var buff_attack_vfx_start_modulate: Color = Color.WHITE
var buff_attack_vfx_start_visible: bool = false

var hurt_icon_tween: Tween = null
var buff_attack_vfx_tween: Tween = null


func _ready() -> void:
	_cache_hurt_icon()
	_cache_buff_attack_vfx()
	reset_vfx_feedback()


func play_hurt_icon_feedback(profile: CardFeedbackProfile) -> void:
	if hurt_icon == null:
		return

	if profile == null:
		return

	if hurt_icon_tween != null:
		hurt_icon_tween.kill()
		hurt_icon_tween = null

	hurt_icon.visible = true
	hurt_icon.position = hurt_icon_start_position
	hurt_icon.scale = profile.hurt_icon_start_scale

	var start_color := hurt_icon_start_modulate
	start_color.a = profile.hurt_icon_start_alpha
	hurt_icon.modulate = start_color

	hurt_icon_tween = create_tween()
	hurt_icon_tween.set_parallel(true)

	hurt_icon_tween.tween_property(
		hurt_icon,
		"scale",
		profile.hurt_icon_end_scale,
		profile.hurt_icon_pop_time + profile.hurt_icon_fade_time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var end_color := hurt_icon_start_modulate
	end_color.a = profile.hurt_icon_end_alpha

	hurt_icon_tween.tween_property(
		hurt_icon,
		"modulate",
		end_color,
		profile.hurt_icon_fade_time
	).set_delay(profile.hurt_icon_pop_time)

	await hurt_icon_tween.finished

	hurt_icon.visible = false
	hurt_icon_tween = null


func play_buffed_attack_vfx(profile: CardFeedbackProfile) -> void:
	if buff_attack_vfx_sprite == null:
		_debug_print("Missing buff_attack_vfx_sprite.")
		return

	if profile == null:
		_debug_print("Missing profile.")
		return

	if buff_attack_vfx_tween != null:
		buff_attack_vfx_tween.kill()
		buff_attack_vfx_tween = null

	buff_attack_vfx_sprite.visible = true
	buff_attack_vfx_sprite.position = buff_attack_vfx_start_position
	buff_attack_vfx_sprite.scale = buff_attack_vfx_start_scale

	var start_color := buff_attack_vfx_start_modulate
	start_color.a = profile.buff_attack_vfx_start_alpha
	buff_attack_vfx_sprite.modulate = start_color

	var end_position := buff_attack_vfx_start_position + Vector2(
		0.0,
		-profile.buff_attack_vfx_rise_distance
	)

	var end_color := buff_attack_vfx_start_modulate
	end_color.a = profile.buff_attack_vfx_end_alpha

	buff_attack_vfx_tween = create_tween()
	buff_attack_vfx_tween.set_parallel(true)

	buff_attack_vfx_tween.tween_property(
		buff_attack_vfx_sprite,
		"position",
		end_position,
		profile.buff_attack_vfx_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	buff_attack_vfx_tween.tween_property(
		buff_attack_vfx_sprite,
		"modulate",
		end_color,
		profile.buff_attack_vfx_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	await buff_attack_vfx_tween.finished

	buff_attack_vfx_sprite.visible = false
	buff_attack_vfx_sprite.position = buff_attack_vfx_start_position
	buff_attack_vfx_sprite.scale = buff_attack_vfx_start_scale
	buff_attack_vfx_sprite.modulate = buff_attack_vfx_start_modulate
	buff_attack_vfx_tween = null


func reset_vfx_feedback() -> void:
	if hurt_icon_tween != null:
		hurt_icon_tween.kill()
		hurt_icon_tween = null

	if buff_attack_vfx_tween != null:
		buff_attack_vfx_tween.kill()
		buff_attack_vfx_tween = null

	if hurt_icon != null:
		hurt_icon.position = hurt_icon_start_position
		hurt_icon.scale = hurt_icon_start_scale
		hurt_icon.modulate = hurt_icon_start_modulate
		hurt_icon.visible = hurt_icon_start_visible

	if buff_attack_vfx_sprite != null:
		buff_attack_vfx_sprite.position = buff_attack_vfx_start_position
		buff_attack_vfx_sprite.scale = buff_attack_vfx_start_scale
		buff_attack_vfx_sprite.modulate = buff_attack_vfx_start_modulate
		buff_attack_vfx_sprite.visible = false


func _cache_hurt_icon() -> void:
	if hurt_icon == null:
		return

	hurt_icon_start_position = hurt_icon.position
	hurt_icon_start_scale = hurt_icon.scale
	hurt_icon_start_modulate = hurt_icon.modulate
	hurt_icon_start_visible = hurt_icon.visible


func _cache_buff_attack_vfx() -> void:
	if buff_attack_vfx_sprite == null:
		return

	buff_attack_vfx_start_position = buff_attack_vfx_sprite.position
	buff_attack_vfx_start_scale = buff_attack_vfx_sprite.scale
	buff_attack_vfx_start_modulate = buff_attack_vfx_sprite.modulate
	buff_attack_vfx_start_visible = buff_attack_vfx_sprite.visible


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CardVfxFeedback] ", message)
