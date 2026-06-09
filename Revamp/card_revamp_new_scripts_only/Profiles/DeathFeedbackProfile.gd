extends Resource
class_name DeathFeedbackProfile

@export var scale_enabled: bool = true
@export var death_scale: Vector2 = Vector2(0.0, 0.0)
@export var scale_time: float = 0.2
@export var shake_enabled: bool = false
@export var shake_distance: float = 5.0
@export var shake_time: float = 0.04
@export var shake_count: int = 2
@export var audio_enabled: bool = true
@export var audio_stream: AudioStream
