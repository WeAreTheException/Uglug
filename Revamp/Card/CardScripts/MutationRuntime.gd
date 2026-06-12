extends Resource
class_name MutationRuntime

enum RuntimeState {
	ACTIVE,
	CONSUMED,
	DISABLED,
	EXPIRED
}

@export var mutation: Mutation

var owner_card: CardRoot = null

var state: RuntimeState = RuntimeState.ACTIVE

var is_active: bool = true
var uses_left: int = -1
var duration_turns: int = -1
var is_greyed_out: bool = false

var is_base_mutation: bool = false
var can_inherit: bool = true

var stack_count: int = 1


func setup(new_mutation: Mutation, new_owner_card: CardRoot) -> void:
	mutation = new_mutation
	owner_card = new_owner_card

	state = RuntimeState.ACTIVE
	is_active = true
	uses_left = -1
	duration_turns = -1
	is_greyed_out = false
	is_base_mutation = false
	can_inherit = true
	stack_count = 1


func can_use() -> bool:
	if mutation == null:
		return false

	return state == RuntimeState.ACTIVE


func can_be_inherited() -> bool:
	if mutation == null:
		return false

	if is_base_mutation:
		return false

	if not can_inherit:
		return false

	if state != RuntimeState.ACTIVE:
		return false

	return true


func consume_use() -> void:
	if uses_left > 0:
		uses_left -= 1

	if uses_left == 0:
		consume()


func consume() -> void:
	state = RuntimeState.CONSUMED
	is_active = false
	is_greyed_out = true


func disable() -> void:
	state = RuntimeState.DISABLED
	is_active = false
	is_greyed_out = true


func expire() -> void:
	state = RuntimeState.EXPIRED
	is_active = false
	is_greyed_out = true


func deactivate() -> void:
	disable()


func reactivate() -> void:
	state = RuntimeState.ACTIVE
	is_active = true
	is_greyed_out = false


func tick_turn_duration() -> void:
	if duration_turns <= 0:
		return

	duration_turns -= 1

	if duration_turns <= 0:
		expire()


func is_consumed() -> bool:
	return state == RuntimeState.CONSUMED


func is_disabled() -> bool:
	return state == RuntimeState.DISABLED


func is_expired() -> bool:
	return state == RuntimeState.EXPIRED


func is_available() -> bool:
	return state == RuntimeState.ACTIVE
