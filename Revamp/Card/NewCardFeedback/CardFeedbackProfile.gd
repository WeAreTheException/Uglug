extends Resource
class_name CardFeedbackProfile

@export_group("Timing")
@export var duration: float = 0.16
@export var return_duration: float = 0.10
@export var delay_before_number_change: float = 0.08

@export_group("Motion")
@export var scale_amount: Vector2 = Vector2(1.12, 0.88)
@export var shake_amount: Vector2 = Vector2(6.0, 0.0)
@export var jump_distance: float = 12.0

@export_group("Flicker")
@export var flicker_count: int = 3
@export var flicker_color: Color = Color(1.0, 0.2, 0.2, 1.0)

@export_group("Debug")
@export var profile_name: String = "Feedback Profile"
