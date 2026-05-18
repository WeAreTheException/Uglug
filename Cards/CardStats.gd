extends Node
class_name CardStats

@export var stats_visual: Stats

var current_attack: int = 0
var current_health: int = 0
var current_cost: int = 0
var current_worth: int = 0

func setup_from_card_data(data: CardData) -> void:
	if data == null:
		return

	current_attack = data.attack
	current_health = data.health
	current_cost = data.cost
	current_worth = data.worth

	if stats_visual != null:
		stats_visual.setup_from_card_data(data)
	else:
		update_visuals()

func apply_stat_bonus(attack_bonus: int, health_bonus: int) -> void:
	current_attack += attack_bonus
	current_health += health_bonus
	update_visuals()

func set_attack(value: int) -> void:
	current_attack = max(value, 0)
	update_attack_visual()

func set_health(value: int) -> void:
	current_health = max(value, 0)
	update_health_visual()

func set_cost(value: int) -> void:
	current_cost = max(value, 0)
	update_cost_visual()

func set_worth(value: int) -> void:
	current_worth = max(value, 0)

func take_damage(amount: int) -> void:
	current_health -= amount

	if current_health < 0:
		current_health = 0

	update_health_visual()

func is_dead() -> bool:
	return current_health <= 0

func update_visuals() -> void:
	update_attack_visual()
	update_health_visual()
	update_cost_visual()

func update_attack_visual() -> void:
	if stats_visual != null:
		stats_visual.update_attack(current_attack)

func update_health_visual() -> void:
	if stats_visual != null:
		stats_visual.update_health(current_health)

func update_cost_visual() -> void:
	if stats_visual != null:
		stats_visual.update_cost(current_cost)
