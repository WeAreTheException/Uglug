extends Resource
class_name MutationRuntime

enum RuntimeState {
	ACTIVE,
	CONSUMED,
	DISABLED,
	EXPIRED
}

signal visual_active_changed(runtime: MutationRuntime, is_visual_active: bool)
signal visual_triggered(runtime: MutationRuntime, duration: float)
signal runtime_state_changed(runtime: MutationRuntime)
signal removal_requested(runtime: MutationRuntime)

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

var is_visual_active: bool = false

var active_visual_sources: Dictionary = {}
var has_requested_removal: bool = false


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

	is_visual_active = false
	active_visual_sources.clear()
	has_requested_removal = false


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


func set_visual_active(value: bool) -> void:
	if is_visual_active == value:
		return

	is_visual_active = value
	visual_active_changed.emit(self, is_visual_active)


func register_active_visual_source(source: Object) -> void:
	if source == null:
		return

	var source_id := source.get_instance_id()

	if active_visual_sources.has(source_id):
		return

	active_visual_sources[source_id] = weakref(source)
	set_visual_active(true)


func unregister_active_visual_source(source: Object) -> void:
	if source == null:
		return

	var source_id := source.get_instance_id()
	active_visual_sources.erase(source_id)
	_cleanup_invalid_visual_sources()
	set_visual_active(not active_visual_sources.is_empty())


func clear_active_visual_sources() -> void:
	active_visual_sources.clear()
	set_visual_active(false)


func trigger_visual(duration_override: float = -1.0) -> void:
	if state != RuntimeState.ACTIVE:
		return

	var duration := duration_override

	if duration < 0.0:
		duration = 0.35

		if mutation != null:
			duration = mutation.activation_outline_duration

	visual_triggered.emit(self, maxf(duration, 0.01))


func consume_use() -> void:
	if uses_left > 0:
		uses_left -= 1

	if uses_left == 0:
		consume()


func consume() -> void:
	if state == RuntimeState.CONSUMED:
		return

	state = RuntimeState.CONSUMED
	is_active = false
	is_greyed_out = true
	clear_active_visual_sources()
	runtime_state_changed.emit(self)
	_request_removal()


func consume_after_visual(duration_override: float = -1.0) -> void:
	if state == RuntimeState.CONSUMED:
		return

	state = RuntimeState.CONSUMED
	is_active = false
	is_greyed_out = false
	clear_active_visual_sources()
	runtime_state_changed.emit(self)

	var duration := duration_override

	if duration < 0.0:
		duration = 0.35

		if mutation != null:
			duration = mutation.activation_outline_duration

	var tree := _get_owner_tree()

	if tree == null or duration <= 0.0:
		_request_removal()
		return

	var timer := tree.create_timer(duration)
	timer.timeout.connect(_request_removal)


func disable() -> void:
	state = RuntimeState.DISABLED
	is_active = false
	is_greyed_out = true
	clear_active_visual_sources()
	runtime_state_changed.emit(self)


func expire() -> void:
	state = RuntimeState.EXPIRED
	is_active = false
	is_greyed_out = true
	clear_active_visual_sources()
	runtime_state_changed.emit(self)


func deactivate() -> void:
	disable()


func reactivate() -> void:
	state = RuntimeState.ACTIVE
	is_active = true
	is_greyed_out = false
	has_requested_removal = false
	runtime_state_changed.emit(self)


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


func _cleanup_invalid_visual_sources() -> void:
	for source_id in active_visual_sources.keys():
		var source_ref: WeakRef = (
			active_visual_sources.get(source_id, null) as WeakRef
		)

		if source_ref == null:
			active_visual_sources.erase(source_id)
			continue

		if source_ref.get_ref() == null:
			active_visual_sources.erase(source_id)


func _request_removal() -> void:
	if has_requested_removal:
		return

	has_requested_removal = true
	removal_requested.emit(self)


func _get_owner_tree() -> SceneTree:
	if owner_card == null:
		return null

	if not is_instance_valid(owner_card):
		return null

	return owner_card.get_tree()
