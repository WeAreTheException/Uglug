extends Node
class_name AttackScreenshakeHandler

@export var attack: Attack

@export var delay_before_shake: float = 0.0
@export var shake_time: float = 0.12
@export var shake_strength: float = 8.0
@export var shake_steps: int = 6


func _ready() -> void:
	if attack == null:
		attack = get_parent() as Attack

	if attack != null:
		attack.attack_hit.connect(_on_attack_hit)


func _on_attack_hit(_context: AttackContext) -> void:
	var camera := get_viewport().get_camera_2d() as ScreenshakeBrain

	if camera == null:
		return

	camera.shake(
		delay_before_shake,
		shake_time,
		shake_strength,
		shake_steps
	)
