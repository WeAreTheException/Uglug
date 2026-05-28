extends Resource
class_name MutationRuntime

@export var mutation: Mutation

var owner_card: CardRoot = null

var is_active: bool = true
var uses_left: int = -1
var duration_turns: int = -1
var is_greyed_out: bool = false

var stack_count: int = 1


func setup(new_mutation: Mutation, new_owner_card: CardRoot) -> void:
	mutation = new_mutation
	owner_card = new_owner_card

	is_active = true
	uses_left = -1
	duration_turns = -1
	is_greyed_out = false
	stack_count = 1


func can_use() -> bool:
	if mutation == null:
		return false

	if not is_active:
		return false

	if uses_left == 0:
		return false

	return true


func consume_use() -> void:
	if uses_left > 0:
		uses_left -= 1

	if uses_left == 0:
		deactivate()


func tick_turn_duration() -> void:
	if duration_turns <= 0:
		return

	duration_turns -= 1

	if duration_turns <= 0:
		deactivate()


func deactivate() -> void:
	is_active = false
	is_greyed_out = true


func reactivate() -> void:
	is_active = true
	is_greyed_out = false
