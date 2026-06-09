extends Node
class_name AttackSequencer

func build_steps(card: CardRoot) -> Array[AttackStep]:
	var legacy_events := _collect_legacy_events(card)
	legacy_events = _modify_legacy_sequence(card, legacy_events)
	return _events_to_steps(card, legacy_events)

func _collect_legacy_events(card: CardRoot) -> Array[String]:
	var events: Array[String] = []
	if card == null or card.functionality_root == null:
		return [AttackEvents.FORWARD]
	var mutations := card.functionality_root.mutations
	if mutations == null:
		return [AttackEvents.FORWARD]
	for runtime in mutations.get_active_runtimes():
		if runtime != null and runtime.mutation != null:
			runtime.mutation.add_attack_events(runtime, events)
	if events.is_empty():
		events.append(AttackEvents.FORWARD)
	return events

func _modify_legacy_sequence(card: CardRoot, events: Array[String]) -> Array[String]:
	if card == null or card.functionality_root == null:
		return events
	var mutations := card.functionality_root.mutations
	if mutations == null:
		return events
	for runtime in mutations.get_active_runtimes():
		if runtime != null and runtime.mutation != null:
			events = runtime.mutation.modify_attack_sequence(runtime, events)
	return events

func _events_to_steps(card: CardRoot, events: Array[String]) -> Array[AttackStep]:
	var steps: Array[AttackStep] = []
	for event in events:
		steps.append(_make_step(card, event))
	return steps

func _make_step(card: CardRoot, event: String) -> AttackStep:
	if event == AttackEvents.FORWARD:
		return AttackStepFactory.base_event(event)
	var runtime := _first_runtime_that_added_steps(card)
	return AttackStepFactory.mutation_event(event, runtime)

func _first_runtime_that_added_steps(card: CardRoot) -> MutationRuntime:
	if card == null or card.functionality_root == null:
		return null
	var mutations := card.functionality_root.mutations
	if mutations == null:
		return null
	for runtime in mutations.get_active_runtimes():
		if runtime != null and runtime.mutation != null:
			return runtime
	return null
