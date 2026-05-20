extends Node
class_name AntlerAttackExecutor

var card: Card = null


func _ready() -> void:
	card = get_parent() as Card


func resolve_card_attack(target: Card, attack_anim: Node) -> void:
	_refresh_card()

	if card == null:
		return

	if target == null:
		return

	if attack_anim != null and attack_anim.has_method("play_attack"):
		attack_anim.play_attack(target)

	var damage := card.current_attack

	for mutation in card.base_mutations:
		if mutation != null:
			damage = mutation.modify_damage(card, target, damage)

	for mutation in card.additional_mutations:
		if mutation != null:
			damage = mutation.modify_damage(card, target, damage)

	print(card.card_name, " ANTLER -> ", target.card_name, " (", damage, " dmg)")

	_flash_slot(target.current_slot)

	target.take_damage(damage, card)


func resolve_direct_attack(slot: NewSlots, attack_anim: Node) -> void:
	_refresh_card()

	if card == null:
		return

	if attack_anim != null and attack_anim.has_method("play_attack"):
		attack_anim.play_attack(null)

	var direct_damage := card.current_attack
	print(card.card_name, " ANTLER direct damage: ", direct_damage)

	_flash_slot(slot)

	if not GDSync.is_host():
		return

	var tree := get_tree()

	if tree == null:
		return

	var tugga := tree.get_first_node_in_group("tugga")

	if tugga != null and tugga.has_method("take_direct_damage"):
		tugga.take_direct_damage(card.owning_peer_id, direct_damage)
	elif tugga != null and tugga.has_method("request_direct_damage"):
		tugga.request_direct_damage(card.owning_peer_id, direct_damage)
	else:
		print("antler direct damage blocked: tugga not found")


func _flash_slot(slot: Node) -> void:
	if slot == null:
		return

	if not slot.has_method("flash_damage"):
		return

	slot.flash_damage()


func _refresh_card() -> void:
	if card == null:
		card = get_parent() as Card
