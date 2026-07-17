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
@export var source_target_delay: float = 0.2

static var global_feedback_collection_active: bool = false
static var global_feedback_events: Array[StatFeedbackEvent] = []
static var global_feedback_stats: Array[CardStats] = []

var owner_card: CardRoot = null

var base_attack: int = 0
var base_health: int = 0
var base_cost: int = 0
var base_worth: int = 0

var damage_taken: int = 0

var modifiers: Array[StatModifier] = []

var stat_refresh_batch_depth: int = 0

var batch_start_attack: int = 0
var batch_start_health: int = 0
var batch_start_cost: int = 0
var batch_start_worth: int = 0

var batch_remaining_positive_by_stat: Dictionary = {}
var batch_remaining_negative_by_stat: Dictionary = {}


static func begin_global_stat_feedback_collection() -> void:
	global_feedback_collection_active = true
	global_feedback_events.clear()
	global_feedback_stats.clear()


static func flush_global_stat_feedback_collection() -> void:
	var grouped_events: Array[StatFeedbackEvent] = []

	for event: StatFeedbackEvent in global_feedback_events:
		if event == null:
			continue

		if not event.is_valid_event():
			continue

		if event.target_card == null:
			continue

		if not is_instance_valid(event.target_card):
			continue

		if event.target_card.stats == null:
			continue

		var consumed_event: StatFeedbackEvent = event.target_card.stats._consume_batch_event(event)

		if consumed_event == null:
			continue

		_add_grouped_event(grouped_events, consumed_event)

	for grouped_event: StatFeedbackEvent in grouped_events:
		if grouped_event == null:
			continue

		if grouped_event.target_card == null:
			continue

		if not is_instance_valid(grouped_event.target_card):
			continue

		if grouped_event.target_card.stats == null:
			continue

		grouped_event.target_card.stats._schedule_feedback_event(grouped_event)

	for stats: CardStats in global_feedback_stats:
		if stats == null:
			continue

		if not is_instance_valid(stats):
			continue

		stats._emit_unconsumed_batch_changes()

	global_feedback_collection_active = false
	global_feedback_events.clear()
	global_feedback_stats.clear()


static func _add_grouped_event(
	grouped_events: Array[StatFeedbackEvent],
	new_event: StatFeedbackEvent
) -> void:
	for existing_event: StatFeedbackEvent in grouped_events:
		if existing_event == null:
			continue

		if existing_event.can_merge_with(new_event):
			existing_event.merge_from(new_event)
			return

	grouped_events.append(new_event)


static func _register_global_feedback_stats(stats: CardStats) -> void:
	if stats == null:
		return

	if global_feedback_stats.has(stats):
		return

	global_feedback_stats.append(stats)


static func _register_global_feedback_event(event: StatFeedbackEvent) -> void:
	if event == null:
		return

	global_feedback_events.append(event)


func setup_from_data(data: CardData) -> void:
	if data == null:
		return

	base_attack = data.attack
	base_health = data.health
	base_cost = data.cost
	base_worth = data.worth

	damage_taken = 0
	modifiers.clear()

	stat_refresh_batch_depth = 0
	batch_remaining_positive_by_stat.clear()
	batch_remaining_negative_by_stat.clear()

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


func begin_stat_refresh_batch() -> void:
	stat_refresh_batch_depth += 1

	if stat_refresh_batch_depth > 1:
		return

	batch_start_attack = get_attack()
	batch_start_health = get_health()
	batch_start_cost = get_cost()
	batch_start_worth = get_worth()

	batch_remaining_positive_by_stat.clear()
	batch_remaining_negative_by_stat.clear()

	CardStats._register_global_feedback_stats(self)


func end_stat_refresh_batch() -> void:
	if stat_refresh_batch_depth <= 0:
		return

	stat_refresh_batch_depth -= 1

	if stat_refresh_batch_depth > 0:
		return

	_build_batch_remaining_changes()


func add_modifier(modifier: StatModifier) -> void:
	if modifier == null:
		return

	modifiers.append(modifier)

	if _is_in_stat_refresh_batch():
		_track_batch_modifier(modifier)
		return

	if modifier.amount > 0:
		stat_buffed.emit(modifier.stat_name, modifier.amount)
		_schedule_feedback_event(
			_build_feedback_event(
				modifier,
				"buffer",
				"buffed",
				abs(modifier.amount)
			)
		)
		return

	if modifier.amount < 0:
		stat_debuffed.emit(modifier.stat_name, abs(modifier.amount))
		_schedule_feedback_event(
			_build_feedback_event(
				modifier,
				"debuffer",
				"debuffed",
				abs(modifier.amount)
			)
		)
		return

	_emit_all_changed()


func remove_modifier(modifier: StatModifier) -> void:
	if modifier == null:
		return

	modifiers.erase(modifier)

	_clamp_damage_taken()

	if _is_in_stat_refresh_batch():
		return

	_emit_all_changed()


func remove_modifiers_from_source(source: Object) -> void:
	for i in range(modifiers.size() - 1, -1, -1):
		var modifier: StatModifier = modifiers[i]

		if modifier == null:
			continue

		if modifier.source == source:
			modifiers.remove_at(i)

	_clamp_damage_taken()

	if _is_in_stat_refresh_batch():
		return

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

	stat_refresh_batch_depth = 0
	batch_remaining_positive_by_stat.clear()
	batch_remaining_negative_by_stat.clear()

	_emit_all_changed()


func _build_batch_remaining_changes() -> void:
	_set_remaining_change_for_stat("attack", batch_start_attack, get_attack())
	_set_remaining_change_for_stat("health", batch_start_health, get_health())
	_set_remaining_change_for_stat("cost", batch_start_cost, get_cost())
	_set_remaining_change_for_stat("worth", batch_start_worth, get_worth())


func _set_remaining_change_for_stat(
	stat_name: String,
	old_value: int,
	new_value: int
) -> void:
	var difference: int = new_value - old_value

	if difference > 0:
		batch_remaining_positive_by_stat[stat_name] = difference
		return

	if difference < 0:
		batch_remaining_negative_by_stat[stat_name] = abs(difference)


func _track_batch_modifier(modifier: StatModifier) -> void:
	if modifier == null:
		return

	if modifier.amount > 0:
		CardStats._register_global_feedback_event(
			_build_feedback_event(
				modifier,
				"buffer",
				"buffed",
				abs(modifier.amount)
			)
		)
		return

	if modifier.amount < 0:
		CardStats._register_global_feedback_event(
			_build_feedback_event(
				modifier,
				"debuffer",
				"debuffed",
				abs(modifier.amount)
			)
		)


func _build_feedback_event(
	modifier: StatModifier,
	source_feedback_type: String,
	target_feedback_type: String,
	amount: int
) -> StatFeedbackEvent:
	var event := StatFeedbackEvent.new()

	event.setup(
		_get_source_card_from_modifier(modifier),
		owner_card,
		source_feedback_type,
		target_feedback_type,
		modifier.stat_name,
		amount,
		modifier
	)

	return event


func _consume_batch_event(event: StatFeedbackEvent) -> StatFeedbackEvent:
	if event == null:
		return null

	if event.stat_names.is_empty():
		return null

	var consumed_event := StatFeedbackEvent.new()
	consumed_event.source_card = event.source_card
	consumed_event.target_card = event.target_card
	consumed_event.source_feedback_type = event.source_feedback_type
	consumed_event.target_feedback_type = event.target_feedback_type
	consumed_event.modifier = event.modifier

	for stat_name: String in event.stat_names:
		var amount: int = int(event.stat_amounts.get(stat_name, 0))

		if amount <= 0:
			continue

		var used_amount: int = _consume_stat_amount_for_event(
			event.target_feedback_type,
			stat_name,
			amount
		)

		if used_amount <= 0:
			continue

		consumed_event.add_stat_change(stat_name, used_amount)

		if event.target_feedback_type == "buffed":
			stat_buffed.emit(stat_name, used_amount)

		if event.target_feedback_type == "debuffed":
			stat_debuffed.emit(stat_name, used_amount)

	if consumed_event.stat_names.is_empty():
		return null

	return consumed_event


func _consume_stat_amount_for_event(
	target_feedback_type: String,
	stat_name: String,
	amount: int
) -> int:
	if target_feedback_type == "buffed":
		return _consume_remaining_positive_amount(stat_name, amount)

	if target_feedback_type == "debuffed":
		return _consume_remaining_negative_amount(stat_name, amount)

	return 0


func _consume_remaining_positive_amount(stat_name: String, amount: int) -> int:
	var remaining: int = int(
		batch_remaining_positive_by_stat.get(stat_name, 0)
	)

	if remaining <= 0:
		return 0

	var used_amount: int = min(amount, remaining)
	batch_remaining_positive_by_stat[stat_name] = remaining - used_amount

	return used_amount


func _consume_remaining_negative_amount(stat_name: String, amount: int) -> int:
	var remaining: int = int(
		batch_remaining_negative_by_stat.get(stat_name, 0)
	)

	if remaining <= 0:
		return 0

	var used_amount: int = min(amount, remaining)
	batch_remaining_negative_by_stat[stat_name] = remaining - used_amount

	return used_amount


func _emit_unconsumed_batch_changes() -> void:
	for stat_name in batch_remaining_positive_by_stat.keys():
		var remaining: int = int(batch_remaining_positive_by_stat.get(stat_name, 0))

		if remaining > 0:
			_emit_changed_for_stat(str(stat_name))

	for stat_name in batch_remaining_negative_by_stat.keys():
		var remaining: int = int(batch_remaining_negative_by_stat.get(stat_name, 0))

		if remaining > 0:
			_emit_changed_for_stat(str(stat_name))

	batch_remaining_positive_by_stat.clear()
	batch_remaining_negative_by_stat.clear()


func _is_in_stat_refresh_batch() -> bool:
	return stat_refresh_batch_depth > 0


func _schedule_feedback_event(event: StatFeedbackEvent) -> void:
	if event == null:
		return

	if not event.is_valid_event():
		return

	StatFeedbackQueueHelper.enqueue(
		self,
		feedback_step_delay,
		func() -> void:
			_flush_event_source_feedback(event)
	)

	StatFeedbackQueueHelper.enqueue(
		self,
		source_target_delay,
		func() -> void:
			_flush_event_target_feedback(event)
	)


func _flush_event_source_feedback(event: StatFeedbackEvent) -> void:
	if event == null:
		return

	event.play_source_feedback()

	if not print_feedback_debug:
		return

	print(
		"STAT SOURCE: ",
		event.source_feedback_type,
		" feedback | card=",
		event.get_debug_source_name(),
		" target=",
		event.get_debug_target_name(),
		" stats=",
		event.get_debug_stats_text()
	)


func _flush_event_target_feedback(event: StatFeedbackEvent) -> void:
	if event == null:
		return

	for stat_name: String in event.stat_names:
		_emit_changed_for_stat(stat_name)

	event.play_target_feedback()

	if not print_feedback_debug:
		return

	print(
		"STAT TARGET: ",
		event.target_feedback_type,
		" feedback | card=",
		event.get_debug_target_name(),
		" source=",
		event.get_debug_source_name(),
		" stats=",
		event.get_debug_stats_text()
	)


func _emit_changed_for_stat(stat_name: String) -> void:
	match stat_name:
		"attack":
			attack_changed.emit(get_attack())
			stats_changed.emit()
			return

		"health":
			health_changed.emit(get_health())
			stats_changed.emit()
			return

		"cost":
			cost_changed.emit(get_cost())
			stats_changed.emit()
			return

		"worth":
			worth_changed.emit(get_worth())
			stats_changed.emit()
			return

	_emit_all_changed()


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
