extends Node
class_name AttackTargetResolver

const FORWARD := "FORWARD"
const LEFT := "LEFT"
const RIGHT := "RIGHT"


func resolve_target(slots_root: SlotsRoot, context: AttackContext) -> void:
	if slots_root == null:
		return

	if context == null:
		return

	if context.origin_slot == null:
		return

	var owner := slots_root.get_owner_of_slot(context.origin_slot)
	var enemy_owner := slots_root.get_enemy_owner(owner)

	match context.attack_event:
		FORWARD:
			context.target_slot = slots_root.get_slot(
				enemy_owner,
				context.origin_slot.slot_index
			)

		LEFT:
			context.target_slot = slots_root.get_slot(
				enemy_owner,
				context.origin_slot.slot_index - 1
			)

		RIGHT:
			context.target_slot = slots_root.get_slot(
				enemy_owner,
				context.origin_slot.slot_index + 1
			)

	_apply_mutation_target_modifiers(context)


func _apply_mutation_target_modifiers(context: AttackContext) -> void:
	if context == null:
		return

	if context.attacker_card == null:
		return

	if context.attacker_card.mutations == null:
		return

	context.attacker_card.mutations.modify_attack_target(context)
