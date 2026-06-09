extends Resource
class_name HurtFeedbackProfile

@export var shake_enabled: bool = true
@export var shake_distance: float = 8.0
@export var shake_time: float = 0.04
@export var shake_count: int = 3
@export var flash_enabled: bool = true
@export var flash_time: float = 0.08
@export var scale_enabled: bool = true
@export var hit_scale: Vector2 = Vector2(1.08, 0.92)
@export var scale_time: float = 0.06
@export var audio_enabled: bool = true
@export var audio_stream: AudioStream
