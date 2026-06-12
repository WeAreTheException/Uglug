extends Resource
class_name AttackExchangeContext

var attack_context: AttackContext = null

var attacker_card: CardRoot = null
var attacker_slot: Slot = null
var attacker_owner: SlotRow.SlotOwner

var target_card: CardRoot = null
var target_slot: Slot = null
var target_owner: SlotRow.SlotOwner

var requested_damage: int = 0
var final_damage: int = 0
var actual_damage: int = 0
var blocked_damage: int = 0
var overflow_damage: int = 0

var is_direct_damage := false
var is_overflow_damage := false
var is_intercepted := false
var is_committed := false

var attacker_pending_death := false
var target_pending_death := false

var pending_score_damage: int = 0

var active_mutation_runtimes: Array = []


func setup_from_attack_context(context: AttackContext) -> void:
	attack_context = context

	if context == null:
		return

	attacker_card = context.attacker_card
	attacker_slot = context.origin_slot
	attacker_owner = context.attacker_owner

	target_slot = context.target_slot
	target_owner = context.target_owner

	if target_slot != null:
		target_card = target_slot.current_card


func commit_hit() -> void:
	is_committed = true


func set_damage(amount: int) -> void:
	requested_damage = max(amount, 0)
	final_damage = requested_damage


func set_final_damage(amount: int) -> void:
	final_damage = max(amount, 0)


func set_actual_damage(amount: int) -> void:
	actual_damage = max(amount, 0)
	blocked_damage = max(final_damage - actual_damage, 0)
	overflow_damage = max(final_damage - actual_damage, 0)


func set_blocked_damage(amount: int) -> void:
	blocked_damage = max(amount, 0)
	actual_damage = max(final_damage - blocked_damage, 0)


func set_overflow_damage(amount: int) -> void:
	overflow_damage = max(amount, 0)


func add_pending_score_damage(amount: int) -> void:
	pending_score_damage += max(amount, 0)


func mark_attacker_pending_death() -> void:
	attacker_pending_death = true


func mark_target_pending_death() -> void:
	target_pending_death = true


func is_attacker_valid_for_future_steps() -> bool:
	if attacker_card == null:
		return false

	if not is_instance_valid(attacker_card):
		return false

	if attacker_pending_death:
		return false

	if attacker_card.stats != null and attacker_card.stats.is_dead():
		return false

	if attacker_card.get_current_slot() == null:
		return false

	return true


func is_target_valid_for_damage() -> bool:
	if target_card == null:
		return false

	if not is_instance_valid(target_card):
		return false

	if target_pending_death:
		return false

	if target_card.stats != null and target_card.stats.is_dead():
		return false

	if target_card.get_current_slot() == null:
		return false

	return true


func can_damage_attacker_again() -> bool:
	if attacker_card == null:
		return false

	if not is_instance_valid(attacker_card):
		return false

	if attacker_pending_death:
		return false

	if attacker_card.stats != null and attacker_card.stats.is_dead():
		return false

	return true


func add_active_mutation_runtime(runtime) -> void:
	if runtime == null:
		return

	if active_mutation_runtimes.has(runtime):
		return

	active_mutation_runtimes.append(runtime)


func clear_active_mutation_runtimes() -> void:
	active_mutation_runtimes.clear()
