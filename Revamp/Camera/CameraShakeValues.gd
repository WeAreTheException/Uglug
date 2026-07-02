extends Node
class_name CameraShakeValues

@export_group("Trauma")
@export var trauma_decay_per_second: float = 1.25
@export var trauma_exponent: float = 2.0
@export var max_trauma: float = 1.0

@export_group("Hurt Trauma")
@export var hurt_trauma_amount: float = 0.75

@export_group("Noise Shake")
@export var max_offset: Vector2 = Vector2(28.0, 16.0)
@export var max_rotation_degrees: float = 4.0
@export var noise_frequency: float = 38.0
@export var noise_seed: int = 4127

@export_group("Earthquake Bias")
@export var horizontal_multiplier: float = 1.35
@export var vertical_multiplier: float = 0.85
@export var rotation_multiplier: float = 1.0

@export_group("Impact Kick")
@export var snap_back_before_new_trauma: bool = true
@export var hurt_impact_offset: Vector2 = Vector2(10.0, 14.0)
@export var hurt_impact_velocity: Vector2 = Vector2(-260.0, -180.0)
@export var hurt_impact_rotation_degrees: float = -2.5
@export var hurt_impact_rotation_velocity_degrees: float = 55.0

@export_group("Spring Return")
@export var spring_strength: float = 42.0
@export var damping: float = 11.0
@export var rotation_spring_strength: float = 45.0
@export var rotation_damping: float = 12.0
