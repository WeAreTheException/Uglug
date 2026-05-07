extends Node
class_name CombatManager

func _ready() -> void:
	GDSync.expose_node(self)
	GDSync.expose_func(request_attack_from_host)
	GDSync.expose_func(commit_attack_remote)

	print("CombatManager ready / GDSync host = ", GDSync.is_host())

func request_attack(card: Card) -> void:
	if card == null:
		return

	if card.multiplayer_card_id < 0:
		print("attack sync blocked: card has no multiplayer_card_id")
		return

	var my_peer_id := int(GDSync.get_client_id())

	if GDSync.is_host():
		_host_resolve_attack(my_peer_id, card.multiplayer_card_id)
	else:
		GDSync.call_func(request_attack_from_host, my_peer_id, card.multiplayer_card_id)

func request_attack_from_host(requesting_peer_id: int, attacker_card_id: int) -> void:
	if not GDSync.is_host():
		return

	_host_resolve_attack(requesting_peer_id, attacker_card_id)

func _host_resolve_attack(requesting_peer_id: int, attacker_card_id: int) -> void:
	var attacker := find_card_by_id(attacker_card_id)

	if attacker == null:
		print("attack blocked: attacker missing on host id=", attacker_card_id)
		return

	if attacker.owning_peer_id != requesting_peer_id:
		print("attack blocked: peer does not own card")
		return

	GDSync.call_func_all(commit_attack_remote, attacker_card_id)

func commit_attack_remote(attacker_card_id: int) -> void:
	var attacker := find_card_by_id(attacker_card_id)

	if attacker == null:
		print("remote attack blocked: attacker missing id=", attacker_card_id)
		return

	if attacker.attack_handler == null:
		print("remote attack blocked: attack_handler missing on ", attacker.card_name)
		return

	attacker.attack_handler.attack()

func find_card_by_id(card_id: int) -> Card:
	var cards := get_tree().get_nodes_in_group("cards")

	for node in cards:
		var card := node as Card

		if card == null:
			continue

		if card.multiplayer_card_id == card_id:
			return card

	return null
