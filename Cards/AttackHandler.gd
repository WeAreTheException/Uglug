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

	var final_target: Card = opposing_card

	for mutation in card.base_mutations:
		if mutation != null:
			final_target = mutation.get_attack_target(card, final_target)

	for mutation in card.additional_mutations:
		if mutation != null:
			final_target = mutation.get_attack_target(card, final_target)

	if attack_anim != null and attack_anim.has_method("play_attack"):
		attack_anim.play_attack(final_target)

	if final_target != null:
		var damage := card.current_attack

		for mutation in card.base_mutations:
			if mutation != null:
				damage = mutation.modify_damage(card, final_target, damage)

		for mutation in card.additional_mutations:
			if mutation != null:
				damage = mutation.modify_damage(card, final_target, damage)

		print(card.card_name, " -> ", final_target.card_name, " (", damage, " dmg)")
		final_target.take_damage(damage, card)
	else:
		var direct_damage := card.current_attack
		print(card.card_name, " direct damage: ", direct_damage)

		if card.battle_scale != null:
			card.battle_scale.add_direct_damage(direct_damage, card.card_owner)

func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
