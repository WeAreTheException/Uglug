extends Node
class_name CardStats

signal stats_changed

signal attack_changed(value: int)
signal health_changed(value: int)
signal cost_changed(value: int)
signal worth_changed(value: int)

signal stat_buffed(stat_name: String, amount: int)
signal stat_debuffed(stat_name: String, amount: int)

@export var print_feedback_debug: bool = true
@export var feedback_step_delay: float = 0.5

var owner_card: CardRoot = null

var base_attack: int = 0
var base_health: int = 0
var base_cost: int = 0
var base_worth: int = 0

var damage_taken: int = 0

var modifiers: Array[StatModifier] = []

var target_buffed_feedback_pending: bool = false
var target_debuffed_feedback_pending: bool = false


func setup_from_data(data: CardData) -> void:
	if data == null:
		return

	base_attack = data.attack
	base_health = data.health
	base_cost = data.cost
	base_worth = data.worth

	damage_taken = 0
	modifiers.clear()

	target_buffed_feedback_pending = false
	target_debuffed_feedback_pending = false

	_emit_all_changed()


func get_attack() -> int:
	return max(base_attack + _get_modifier_total("attack"), 0)


func get_health() -> int:
	return max(get_max_health() - damage_taken, 0)


func get_max_health() -> int:
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
		_schedule_source_feedback(modifier, "buffer")
		_schedule_target_feedback("buffed")
		return

	if modifier.amount < 0:
		stat_debuffed.emit(modifier.stat_name, abs(modifier.amount))
		_schedule_source_feedback(modifier, "debuffer")
		_schedule_target_feedback("debuffed")
		return

	_emit_all_changed()


func remove_modifier(modifier: StatModifier) -> void:
	if modifier == null:
		return

	modifiers.erase(modifier)

	_clamp_damage_taken()
	_emit_all_changed()


func remove_modifiers_from_source(source: Object) -> void:
	for i in range(modifiers.size() - 1, -1, -1):
		var modifier := modifiers[i]

		if modifier == null:
			continue

		if modifier.source == source:
			modifiers.remove_at(i)

	_clamp_damage_taken()
	_emit_all_changed()


func take_damage(amount: int) -> void:
	if amount <= 0:
		return

	damage_taken += amount
	damage_taken = min(damage_taken, get_max_health())

	health_changed.emit(get_health())
	stats_changed.emit()


func heal(amount: int) -> void:
	if amount <= 0:
		return

	damage_taken = max(damage_taken - amount, 0)

	health_changed.emit(get_health())
	stats_changed.emit()


func is_dead() -> bool:
	return get_health() <= 0


func reset_damage_taken() -> void:
	damage_taken = 0
	_emit_all_changed()


func apply_network_values(
	attack: int,
	health: int,
	cost: int,
	worth: int,
	max_health: int
) -> void:
	base_attack = attack
	base_health = max_health
	base_cost = cost
	base_worth = worth
	damage_taken = max(max_health - health, 0)
	modifiers.clear()

	target_buffed_feedback_pending = false
	target_debuffed_feedback_pending = false

	_emit_all_changed()


func _schedule_source_feedback(modifier: StatModifier, feedback_type: String) -> void:
	if modifier == null:
		return

	var source_card := _get_source_card_from_modifier(modifier)

	if source_card == null:
		return

	var key := "_pending_" + feedback_type + "_feedback"

	if bool(source_card.get_meta(key, false)):
		return

	source_card.set_meta(key, true)

	StatFeedbackQueueHelper.enqueue(
		self,
		feedback_step_delay,
		func() -> void:
			_flush_source_feedback(source_card, feedback_type, key)
	)


func _schedule_target_feedback(feedback_type: String) -> void:
	if feedback_type == "buffed":
		if target_buffed_feedback_pending:
			return

		target_buffed_feedback_pending = true

		StatFeedbackQueueHelper.enqueue(
			self,
			feedback_step_delay,
			func() -> void:
				_flush_target_feedback(feedback_type)
		)

		return

	if feedback_type == "debuffed":
		if target_debuffed_feedback_pending:
			return

		target_debuffed_feedback_pending = true

		StatFeedbackQueueHelper.enqueue(
			self,
			feedback_step_delay,
			func() -> void:
				_flush_target_feedback(feedback_type)
		)


func _flush_source_feedback(
	source_card: CardRoot,
	feedback_type: String,
	key: String
) -> void:
	if source_card == null:
		return

	if not is_instance_valid(source_card):
		return

	source_card.set_meta(key, false)

	match feedback_type:
		"buffer":
			source_card.play_buffer_feedback()

		"debuffer":
			source_card.play_debuffer_feedback()

	if not print_feedback_debug:
		return

	print(
		"STAT SOURCE: ",
		feedback_type,
		" feedback | card=",
		source_card.card_name
	)


func _flush_target_feedback(feedback_type: String) -> void:
	if feedback_type == "buffed":
		target_buffed_feedback_pending = false

	if feedback_type == "debuffed":
		target_debuffed_feedback_pending = false

	_emit_all_changed()

	if owner_card != null:
		match feedback_type:
			"buffed":
				owner_card.play_buffed_feedback()

			"debuffed":
				owner_card.play_debuffed_feedback()

	if not print_feedback_debug:
		return

	var debug_card_name := "unknown"

	if owner_card != null:
		debug_card_name = owner_card.card_name

	print(
		"STAT TARGET: ",
		feedback_type,
		" feedback | card=",
		debug_card_name
	)


func _get_source_card_from_modifier(modifier: StatModifier) -> CardRoot:
	if modifier == null:
		return null

	var runtime := modifier.source as MutationRuntime

	if runtime == null:
		return null

	if runtime.owner_card == null:
		return null

	if not is_instance_valid(runtime.owner_card):
		return null

	return runtime.owner_card


func _clamp_damage_taken() -> void:
	damage_taken = min(damage_taken, get_max_health())
	damage_taken = max(damage_taken, 0)


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
