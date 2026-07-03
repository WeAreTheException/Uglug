extends Resource
class_name CardFeedbackProfile

@export_group("Debug")
@export var profile_name: String = "Feedback Profile"

@export_group("Timing")
@export var duration: float = 0.16
@export var return_duration: float = 0.10
@export var delay_before_number_change: float = 0.08

@export_group("Sprite Motion")
@export var scale_amount: Vector2 = Vector2(1.12, 0.88)
@export var shake_amount: Vector2 = Vector2(6.0, 0.0)

@export_group("Text Flicker")
@export var flicker_count: int = 3
@export var flicker_color: Color = Color(1.0, 0.2, 0.2, 1.0)

@export_group("Text Punch")
@export var text_squash_scale: Vector2 = Vector2(1.18, 0.72)
@export var text_stretch_scale: Vector2 = Vector2(0.88, 1.18)
@export var text_neutral_punch_scale: Vector2 = Vector2.ONE
@export var text_squash_time: float = 0.06
@export var text_stretch_time: float = 0.08
@export var text_return_time: float = 0.10

@export_group("Hurt Icon")
@export var hurt_icon_start_scale: Vector2 = Vector2(1.0, 1.0)
@export var hurt_icon_end_scale: Vector2 = Vector2(1.2, 1.2)
@export var hurt_icon_start_alpha: float = 1.0
@export var hurt_icon_end_alpha: float = 0.0
@export var hurt_icon_pop_time: float = 0.05
@export var hurt_icon_fade_time: float = 0.18

@export_group("Hurt SFX")
@export var hurt_sound: AudioStream
@export var hurt_volume_db: float = 0.0
@export var hurt_pitch_min: float = 0.96
@export var hurt_pitch_max: float = 1.04

@export_group("Whole Card Hurt Motion")
@export var hurt_hit_offset: Vector2 = Vector2(0.0, 14.0)
@export var hurt_hit_rotation_degrees: float = 0.8
@export var hurt_hit_time: float = 0.045

@export var hurt_recoil_offset: Vector2 = Vector2(0.0, -4.0)
@export var hurt_recoil_rotation_degrees: float = -0.3
@export var hurt_recoil_time: float = 0.07

@export var hurt_motion_return_time: float = 0.11

@export_group("Buffed Stat Text")
@export var buff_jump_distance: float = 12.0
@export var buff_vibration_amount: Vector2 = Vector2(3.0, 1.0)

@export var buff_up_time: float = 0.08
@export var buff_top_pause_time: float = 0.09
@export var buff_pop_settle_time: float = 0.16
@export var buff_down_time: float = 0.24

@export var buff_up_scale: Vector2 = Vector2(1.2, 1.2)
@export var buff_top_pause_scale: Vector2 = Vector2(1.05, 1.05)
@export var buff_down_pop_scale: Vector2 = Vector2(1.25, 1.12)
@export var buff_neutral_scale: Vector2 = Vector2(1.2, 1.2)

@export_group("Buffed Attack VFX")
@export var buff_attack_vfx_rise_distance: float = 28.0
@export var buff_attack_vfx_duration: float = 0.35
@export var buff_attack_vfx_start_alpha: float = 1.0
@export var buff_attack_vfx_end_alpha: float = 0.0

@export_group("Debuffed Attack VFX")
@export var debuff_attack_vfx_fall_distance: float = 28.0
@export var debuff_attack_vfx_duration: float = 0.35
@export var debuff_attack_vfx_start_alpha: float = 1.0
@export var debuff_attack_vfx_end_alpha: float = 0.0
@export var debuff_attack_vfx_rotation_degrees: float = 180.0
