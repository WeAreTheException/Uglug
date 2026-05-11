extends Node
class_name AttackHandler

@export var attack_anim: Node

var card: Card = null

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

	var opposing_slot = card.current_slot.opposing_slot
	var opposing_card: Card = null

	if opposing_slot != null:
		opposing_card = opposing_slot.current_card

	var targets: Array[Card] = [opposing_card]

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

	if targets.is_empty():
		if attack_anim != null and attack_anim.has_method("play_attack"):
			attack_anim.play_attack(null)

		var direct_damage := card.current_attack
		print(card.card_name, " direct damage: ", direct_damage)

		if card.battle_scale != null:
			card.battle_scale.add_direct_damage(direct_damage, card.card_owner)

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
		target.take_damage(damage, card)


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
