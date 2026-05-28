extends Node
class_name CardStats

signal stats_changed

signal attack_changed(value: int)
signal health_changed(value: int)
signal cost_changed(value: int)
signal worth_changed(value: int)

signal stat_buffed(stat_name: String, amount: int)
signal stat_debuffed(stat_name: String, amount: int)


var base_attack: int = 0
var base_health: int = 0
var base_cost: int = 0
var base_worth: int = 0

var modifiers: Array[StatModifier] = []


func setup_from_data(data: CardData) -> void:
	if data == null:
		return

	base_attack = data.attack
	base_health = data.health
	base_cost = data.cost
	base_worth = data.worth

	modifiers.clear()

	_emit_all_changed()


func get_attack() -> int:
	return max(base_attack + _get_modifier_total("attack"), 0)


func get_health() -> int:
	return max(base_health + _get_modifier_total("health"), 0)


func get_cost() -> int:
	return max(base_cost + _get_modifier_total("cost"), 0)


func get_worth() -> int:
	return max(base_worth + _get_modifier_total("worth"), 0)


func add_modifier(modifier: StatModifier) -> void:
	if modifier == null:
		return

	modifiers.append(modifier)

	if modifier.amount > 0:
		stat_buffed.emit(modifier.stat_name, modifier.amount)

	elif modifier.amount < 0:
		stat_debuffed.emit(modifier.stat_name, abs(modifier.amount))

	_emit_all_changed()


func remove_modifier(modifier: StatModifier) -> void:
	if modifier == null:
		return

	modifiers.erase(modifier)

	_emit_all_changed()


func remove_modifiers_from_source(source: Object) -> void:
	for i in range(modifiers.size() - 1, -1, -1):
		var modifier := modifiers[i]

		if modifier == null:
			continue

		if modifier.source == source:
			modifiers.remove_at(i)

	_emit_all_changed()


func take_damage(amount: int) -> void:
	if amount <= 0:
		return

	base_health = max(base_health - amount, 0)

	health_changed.emit(get_health())
	stats_changed.emit()


func heal(amount: int) -> void:
	if amount <= 0:
		return

	base_health += amount

	health_changed.emit(get_health())
	stats_changed.emit()


func is_dead() -> bool:
	return get_health() <= 0


func _get_modifier_total(stat_name: String) -> int:
	var total := 0

	for modifier in modifiers:
		if modifier == null:
			continue

		if not modifier.is_active:
			continue

		if modifier.stat_name != stat_name:
			continue

		total += modifier.amount

	return total


func _emit_all_changed() -> void:
	attack_changed.emit(get_attack())
	health_changed.emit(get_health())
	cost_changed.emit(get_cost())
	worth_changed.emit(get_worth())

	stats_changed.emit()
