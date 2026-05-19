extends Node
class_name AttackHandler

@export var attack_anim: Node
@export var distant_target_picker: DistantTargetPicker

var card: Card = null


func _ready() -> void:
	card = _find_card_parent()

	if distant_target_picker == null:
		distant_target_picker = _find_distant_target_picker()


func attack() -> void:
	if card == null:
		return

	if card.current_slot == null:
		print("attack blocked")
		return

	if card.current_attack <= 0:
		print(card.card_name, " attack skipped: 0 attack")
		return

	var distant_count := _get_distant_count()

	if distant_count > 0:
		for i in range(distant_count):
			print(card.card_name, " has Distant. Waiting for slot choice ", i + 1, "/", distant_count)

			if distant_target_picker == null:
				print("Distant blocked: distant_target_picker missing")
				continue

			var picked_slot := await distant_target_picker.pick_slot()

			if picked_slot == null:
				print("Distant attack cancelled: no slot picked")
				continue

			_resolve_attack_from_slot(picked_slot)

		return

	var starting_slot: NewSlots = card.current_slot.opposing_slot
	_resolve_attack_from_slot(starting_slot)


func _resolve_attack_from_slot(starting_slot: NewSlots) -> void:
	var opposing_card: Card = null

	if starting_slot != null:
		opposing_card = starting_slot.current_card as Card

	var targets: Array[Card] = []

	if opposing_card != null:
		targets.append(opposing_card)

	for mutation in card.base_mutations:
		if mutation == null:
			continue

		if mutation.has_method("get_attack_targets"):
			targets = mutation.get_attack_targets(card, targets)
		else:
			targets = _apply_single_target_mutation(mutation, targets)

	for mutation in card.additional_mutations:
		if mutation == null:
			continue

		if mutation.has_method("get_attack_targets"):
			targets = mutation.get_attack_targets(card, targets)
		else:
			targets = _apply_single_target_mutation(mutation, targets)

	targets = _clean_targets(targets)

	var direct_attack_slots := _get_direct_attack_slots_from_mutations()

	if targets.is_empty() and starting_slot != null:
		if not direct_attack_slots.has(starting_slot):
			direct_attack_slots.append(starting_slot)

	var direct_attack_count := direct_attack_slots.size()

	if direct_attack_count <= 0:
		direct_attack_count = _get_direct_attack_count_from_mutations()

	if targets.is_empty() and direct_attack_count <= 0:
		direct_attack_count = 1

	for i in range(direct_attack_count):
		if attack_anim != null and attack_anim.has_method("play_attack"):
			attack_anim.play_attack(null)

		var direct_damage := card.current_attack
		print(card.card_name, " direct damage: ", direct_damage)

		var slot_to_flash: Node = null

		if i < direct_attack_slots.size():
			slot_to_flash = direct_attack_slots[i]
		else:
			slot_to_flash = starting_slot

		_flash_slot(slot_to_flash)

		var tree := get_tree()

		if tree == null:
			return

		var tugga := tree.get_first_node_in_group("tugga")

		if tugga != null and tugga.has_method("take_direct_damage"):
			tugga.take_direct_damage(card.owning_peer_id, direct_damage)
		else:
			print("direct damage blocked: tugga not found")

	if targets.is_empty():
		return

	for target in targets:
		if target == null:
			continue

		if attack_anim != null and attack_anim.has_method("play_attack"):
			attack_anim.play_attack(target)

		var damage := card.current_attack

		for mutation in card.base_mutations:
			if mutation != null:
				damage = mutation.modify_damage(card, target, damage)

		for mutation in card.additional_mutations:
			if mutation != null:
				damage = mutation.modify_damage(card, target, damage)

		print(card.card_name, " -> ", target.card_name, " (", damage, " dmg)")

		_flash_slot(target.current_slot)

		target.take_damage(damage, card)


func _get_distant_count() -> int:
	var count := 0

	for mutation in card.base_mutations:
		if mutation != null and mutation.wants_manual_attack_target():
			count += 1

	for mutation in card.additional_mutations:
		if mutation != null and mutation.wants_manual_attack_target():
			count += 1

	return count

func _flash_slot(slot: Node) -> void:
	print("TRY FLASH SLOT: ", slot)

	if slot == null:
		print("flash blocked: slot is null")
		return

	if not slot.has_method("flash_damage"):
		print("flash blocked: slot has no flash_damage method: ", slot.name)
		return

	slot.flash_damage()


func _get_direct_attack_slots_from_mutations() -> Array[NewSlots]:
	var slots: Array[NewSlots] = []

	for mutation in card.base_mutations:
		if mutation == null:
			continue

		if "empty_adjacent_slots" in mutation:
			for slot in mutation.empty_adjacent_slots:
				if slot != null:
					slots.append(slot)

	for mutation in card.additional_mutations:
		if mutation == null:
			continue

		if "empty_adjacent_slots" in mutation:
			for slot in mutation.empty_adjacent_slots:
				if slot != null:
					slots.append(slot)

	return slots


func _get_direct_attack_count_from_mutations() -> int:
	var count := 0

	for mutation in card.base_mutations:
		if mutation == null:
			continue

		if "empty_adjacent_attack_count" in mutation:
			count += mutation.empty_adjacent_attack_count

	for mutation in card.additional_mutations:
		if mutation == null:
			continue

		if "empty_adjacent_attack_count" in mutation:
			count += mutation.empty_adjacent_attack_count

	return count


func _apply_single_target_mutation(mutation: Mutation, targets: Array[Card]) -> Array[Card]:
	if targets.is_empty():
		return targets

	var changed_targets: Array[Card] = []

	for target in targets:
		var new_target: Card = mutation.get_attack_target(card, target)

		if new_target != null:
			changed_targets.append(new_target)

	return changed_targets


func _clean_targets(targets: Array[Card]) -> Array[Card]:
	var cleaned: Array[Card] = []

	for target in targets:
		if target == null:
			continue

		if cleaned.has(target):
			continue

		cleaned.append(target)

	return cleaned


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null

func _find_distant_target_picker() -> DistantTargetPicker:
	if card == null:
		return null

	var picker := card.get_node_or_null("DistantTargetPicker") as DistantTargetPicker

	if picker != null:
		return picker

	return card.find_child("DistantTargetPicker", true, false) as DistantTargetPicker
