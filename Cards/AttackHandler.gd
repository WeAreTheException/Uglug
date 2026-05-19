extends Node
class_name AttackHandler

@export var attack_anim: Node

var card: Card = null
var waiting_for_distant_slot := false
var chosen_distant_slot: NewSlots = null


func _ready() -> void:
	card = _find_card_parent()


func attack() -> void:
	if card == null:
		return

	if card.current_slot == null:
		print("attack blocked")
		return

	if card.current_attack <= 0:
		print(card.card_name, " attack skipped: 0 attack")
		return

	var starting_slot: NewSlots = card.current_slot.opposing_slot

	if _card_wants_manual_attack_slot():
		print(card.card_name, " has Distant. Waiting for slot choice...")
		starting_slot = await _wait_for_distant_slot()

		if starting_slot == null:
			print("Distant attack cancelled: no slot picked")
			return

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

	if targets.is_empty() and starting_slot != null and _card_wants_manual_attack_slot():
		if not direct_attack_slots.has(starting_slot):
			direct_attack_slots.append(starting_slot)

	var direct_attack_count := direct_attack_slots.size()

	if direct_attack_count <= 0:
		direct_attack_count = _get_direct_attack_count_from_mutations()

	if targets.is_empty() and direct_attack_count <= 0:
		direct_attack_count = 1

	for i in direct_attack_count:
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


func _wait_for_distant_slot() -> NewSlots:
	waiting_for_distant_slot = true
	chosen_distant_slot = null

	var tree := get_tree()

	if tree == null:
		waiting_for_distant_slot = false
		return null

	var slots := tree.get_nodes_in_group("slots")

	for slot in slots:
		var new_slot := slot as NewSlots

		if new_slot == null:
			continue

		if not new_slot.slot_clicked.is_connected(_on_distant_slot_clicked):
			new_slot.slot_clicked.connect(_on_distant_slot_clicked)

	while waiting_for_distant_slot:
		tree = get_tree()

		if tree == null:
			waiting_for_distant_slot = false
			return null

		await tree.process_frame

	_disconnect_distant_slots()

	return chosen_distant_slot


func _on_distant_slot_clicked(slot: NewSlots) -> void:
	if not waiting_for_distant_slot:
		return

	if card == null:
		return

	if card.current_slot == null:
		return

	if slot == null:
		return

	if slot.slot_owner == card.current_slot.slot_owner:
		print("Distant blocked: cannot attack own side")
		return

	chosen_distant_slot = slot
	waiting_for_distant_slot = false

	print(card.card_name, " chose Distant slot: ", slot.name)


func _disconnect_distant_slots() -> void:
	var tree := get_tree()

	if tree == null:
		return

	var slots := tree.get_nodes_in_group("slots")

	for slot in slots:
		var new_slot := slot as NewSlots

		if new_slot == null:
			continue

		if new_slot.slot_clicked.is_connected(_on_distant_slot_clicked):
			new_slot.slot_clicked.disconnect(_on_distant_slot_clicked)


func _card_wants_manual_attack_slot() -> bool:
	for mutation in card.base_mutations:
		if _is_distant_mutation(mutation):
			return true

	for mutation in card.additional_mutations:
		if _is_distant_mutation(mutation):
			return true

	return false


func _is_distant_mutation(mutation: Mutation) -> bool:
	if mutation == null:
		return false

	print("checking mutation: ", mutation, " script=", mutation.get_script())

	if mutation.has_method("wants_manual_attack_slot"):
		if mutation.wants_manual_attack_slot():
			print("Distant detected by wants_manual_attack_slot")
			return true

	if mutation is Distant:
		print("Distant detected by class")
		return true

	if mutation.resource_path.to_lower().contains("distant"):
		print("Distant detected by resource path")
		return true

	return false


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
