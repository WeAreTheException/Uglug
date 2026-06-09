extends Resource
class_name AttackFeedbackProfile

@export var windup_time: float = 0.16
@export var attack_time: float = 0.04
@export var hit_hold_time: float = 0.08
@export var return_time: float = 0.2
@export var windup_scale: Vector2 = Vector2(0.9, 1.1)
@export var attack_scale: Vector2 = Vector2(1.1, 0.9)
@export var forward_windup_distance: float = 18.0
@export var forward_attack_distance: float = 200.0
@export var diagonal_windup_distance: float = 20.0
@export var diagonal_attack_distance: float = 220.0
@export var windup_rotation_degrees: float = -10.0
@export var attack_rotation_degrees: float = 20.0
@export var attack_z_index: int = 100
