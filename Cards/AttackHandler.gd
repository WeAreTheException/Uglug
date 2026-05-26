extends Node
class_name AttackHandler

@export var attack_anim: Node

var card: Card = null


func _ready() -> void:
	card = _find_card_parent()


func attack() -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if card.current_slot == null:
		print("attack blocked")
		return

	if card.current_attack <= 0:
		print(card.card_name, " attack skipped: 0 attack")
		return

	var target_slot := card.current_slot.opposing_slot

	if target_slot == null:
		return

	var target_card := target_slot.current_card as Card

	if target_card != null and is_instance_valid(target_card):
		_resolve_card_attack(target_card)
	else:
		_resolve_direct_attack(target_slot)


func _resolve_card_attack(target: Card) -> void:
	if target == null:
		return

	if not is_instance_valid(target):
		return

	if attack_anim != null and attack_anim.has_method("play_attack"):
		attack_anim.play_attack(target)

	var damage := card.current_attack

	for mutation in card.get_all_mutations():
		if mutation == null:
			continue

		damage = mutation.modify_damage(card, target, damage)

	print(card.card_name, " -> ", target.card_name, " (", damage, " dmg)")

	_flash_slot(target.current_slot)

	target.take_damage(damage, card)


func _resolve_direct_attack(slot: NewSlots) -> void:
	if attack_anim != null and attack_anim.has_method("play_attack"):
		attack_anim.play_attack(null)

	var direct_damage := card.current_attack

	print(card.card_name, " direct damage: ", direct_damage)

	_flash_slot(slot)

	var tugga := get_tree().get_first_node_in_group("tugga")

	if tugga == null:
		print("direct damage blocked: tugga missing")
		return

	if tugga.has_method("request_direct_damage"):
		tugga.request_direct_damage(card.owning_peer_id, direct_damage)
	elif tugga.has_method("take_direct_damage"):
		tugga.take_direct_damage(card.owning_peer_id, direct_damage)


func _flash_slot(slot: Node) -> void:
	if slot == null:
		return

	if not is_instance_valid(slot):
		return

	if not slot.has_method("flash_damage"):
		return

	slot.flash_damage()


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
