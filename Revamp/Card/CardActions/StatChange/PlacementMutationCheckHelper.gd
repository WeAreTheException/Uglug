extends RefCounted
class_name PlacementMutationCheckHelper


func run(card: CardRoot) -> void:
	if card == null:
		return

	if card.mutations == null:
		return

	var has_source_buffer := false
	var has_source_debuffer := false

	var buffed_targets: Array[CardRoot] = []
	var debuffed_targets: Array[CardRoot] = []

	for runtime in card.mutations.get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		if _has_source_buffer_feedback(runtime):
			has_source_buffer = true

		if _has_source_debuffer_feedback(runtime):
			has_source_debuffer = true

		_collect_buffed_targets(runtime, buffed_targets)
		_collect_debuffed_targets(runtime, debuffed_targets)

	if has_source_buffer:
		print("PLACEMENT SOURCE: buffer feedback | card=", card.card_name)

	if has_source_debuffer:
		print("PLACEMENT SOURCE: debuffer feedback | card=", card.card_name)

	for target in buffed_targets:
		if target != null:
			print("PLACEMENT TARGET: buffed feedback | card=", target.card_name)

	for target in debuffed_targets:
		if target != null:
			print("PLACEMENT TARGET: debuffed feedback | card=", target.card_name)


func _has_source_buffer_feedback(runtime: MutationRuntime) -> bool:
	if runtime.mutation.has_method("has_placement_buff_feedback"):
		return runtime.mutation.has_placement_buff_feedback()

	return false


func _has_source_debuffer_feedback(runtime: MutationRuntime) -> bool:
	if runtime.mutation.has_method("has_placement_debuff_feedback"):
		return runtime.mutation.has_placement_debuff_feedback()

	return false


func _collect_buffed_targets(
	runtime: MutationRuntime,
	targets: Array[CardRoot]
) -> void:
	if not runtime.mutation.has_method("get_placement_buffed_feedback_targets"):
		return

	var found_targets: Array = runtime.mutation.get_placement_buffed_feedback_targets(runtime)

	for target in found_targets:
		_add_unique_card(targets, target)


func _collect_debuffed_targets(
	runtime: MutationRuntime,
	targets: Array[CardRoot]
) -> void:
	if not runtime.mutation.has_method("get_placement_debuffed_feedback_targets"):
		return

	var found_targets: Array = runtime.mutation.get_placement_debuffed_feedback_targets(runtime)

	for target in found_targets:
		_add_unique_card(targets, target)


func _add_unique_card(
	targets: Array[CardRoot],
	card: CardRoot
) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if targets.has(card):
		return

	targets.append(card)
