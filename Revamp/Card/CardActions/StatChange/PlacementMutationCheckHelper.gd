extends RefCounted
class_name PlacementMutationCheckHelper


func run(card: CardRoot) -> void:
	if card == null:
		return

	if card.mutations == null:
		return

	var has_buff_feedback := false
	var has_debuff_feedback := false

	for runtime in card.mutations.get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		if runtime.mutation.has_placement_buff_feedback():
			has_buff_feedback = true

		if runtime.mutation.has_placement_debuff_feedback():
			has_debuff_feedback = true

	if has_buff_feedback:
		print("PLACEMENT CHECK: buff feedback")

	if has_debuff_feedback:
		print("PLACEMENT CHECK: debuff feedback")
