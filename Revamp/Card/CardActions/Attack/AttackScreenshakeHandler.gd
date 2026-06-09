extends Node
class_name AttackScreenshakeHandler

@export var attack: Attack

@export var delay_before_shake: float = 0.0
@export var shake_time: float = 0.12
@export var shake_steps: int = 6

@export var base_strength: float = 4.0
@export var strength_per_damage: float = 2.0
@export var min_strength: float = 4.0
@export var max_strength: float = 14.0


func _ready() -> void:
	if attack == null:
		attack = get_parent() as Attack

	if attack != null:
		attack.attack_hit.connect(_on_attack_hit)


func _on_attack_hit(_context) -> void:
	var camera := get_viewport().get_camera_2d() as ScreenshakeBrain

	if camera == null:
		return

	var card := owner as CardRoot

	if card == null:
		card = get_parent().owner as CardRoot

	if card == null:
		return

	var damage: int = _get_card_damage(card)

	var shake_strength: float = base_strength + (float(damage) * strength_per_damage)
	shake_strength = clampf(shake_strength, min_strength, max_strength)

	camera.shake(
		delay_before_shake,
		shake_time,
		shake_strength,
		shake_steps
	)


func _get_card_damage(card: CardRoot) -> int:
	var card_stats := card.get_node_or_null("Core/CardStats") as CardStats

	if card_stats == null:
		return 1

	return card_stats.get_attack()
