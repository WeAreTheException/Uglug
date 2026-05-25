extends Node
class_name CardSpawnHandler

var card_database: CardDatabase = null
var deck: DeckCount = null
var combat_manager: CombatManager = null
var select_handler: SelectHandler = null
var draw_animation_handler: DeckDrawAnimationHandler = null
var worker_union_buff_handler: WorkerUnionBuffHandler = null

var deck_type_name: String = "UNKNOWN"
var should_apply_worker_union_buff := false


func spawn_card_to_hand(
	target_hand: Node2D,
	new_card_owner: int,
	card_name: String,
	card_id: int,
	owning_peer_id: int,
	deck_root: Node2D
) -> bool:
	if deck == null:
		print("spawn blocked: deck is null on ", deck_type_name)
		return false

	if target_hand == null:
		print("spawn blocked: target_hand is null on ", deck_type_name)
		return false

	if card_database == null:
		print("spawn blocked: card_database is null on ", deck_type_name)
		return false

	if deck.card_scene == null:
		print("spawn blocked: deck.card_scene is null on ", deck_type_name)
		return false

	if not target_hand.has_method("add_card_to_hand"):
		print("spawn blocked: target_hand missing add_card_to_hand on ", deck_type_name)
		return false

	if target_hand.has_method("is_hand_full") and target_hand.is_hand_full():
		print("spawn blocked: hand is full on ", deck_type_name)
		return false

	var data := get_card_data_by_name(card_name)

	if data == null:
		print("spawn blocked: could not find card data named ", card_name, " in ", deck_type_name)
		return false

	var new_card := deck.card_scene.instantiate() as Card

	if new_card == null:
		print("spawn blocked: card_scene did not instantiate Card on ", deck_type_name)
		return false

	_setup_card_runtime_data(
		new_card,
		target_hand,
		new_card_owner,
		card_id,
		owning_peer_id
	)

	target_hand.add_child(new_card)

	if draw_animation_handler != null:
		draw_animation_handler.prepare_card_start_position(new_card, deck_root)
	elif deck_root != null:
		new_card.global_position = deck_root.global_position

	new_card.setup_card(data)

	if should_apply_worker_union_buff and worker_union_buff_handler != null:
		worker_union_buff_handler.try_apply_to_card(new_card)

	if draw_animation_handler != null:
		draw_animation_handler.add_card_to_hand_with_animation(target_hand, new_card)
		draw_animation_handler.play_draw_animation(new_card)
	else:
		target_hand.add_card_to_hand(new_card)

	print("spawned from ", deck_type_name, " deck: ", new_card.card_name)

	return true


func _setup_card_runtime_data(
	card: Card,
	target_hand: Node2D,
	new_card_owner: int,
	card_id: int,
	owning_peer_id: int
) -> void:
	card.multiplayer_card_id = card_id
	card.owning_peer_id = owning_peer_id
	card.card_owner = new_card_owner
	card.player_hand = target_hand
	card.combat_manager = combat_manager

	if new_card_owner == Card.Owner.PLAYER:
		card.select_handler = select_handler
	else:
		card.select_handler = null


func get_card_data_by_name(card_name: String) -> CardData:
	if card_database == null:
		return null

	for data in card_database.cards:
		if data == null:
			continue

		if data.name == card_name:
			return data

	return null
