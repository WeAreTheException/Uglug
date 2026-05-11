extends Node
class_name DeckDrawHandler

enum DeckType {
	WORKER,
	WARRIOR
}

const CARD_DRAW_SPEED = 0.4

static var next_card_id: int = 1

@export var card_database: CardDatabase
@export var deck_type: DeckType = DeckType.WORKER

var combat_manager: CombatManager = null

var deck: DeckCount = null
var player_hand: Node2D = null
var opponent_hand: Node2D = null
var phase_manager: PhaseManager = null
var select_handler: SelectHandler = null

func _ready() -> void:
	GDSync.expose_node(self)
	GDSync.expose_func(request_draw_from_host)
	GDSync.expose_func(commit_draw_remote)

	if deck_type == DeckType.WORKER:
		GDSync.expose_func(pregnant_request_spawn_workers_from_host)
		GDSync.expose_func(pregnant_commit_spawn_worker_card)

	print("DeckDrawHandler ready / deck_type = ", get_deck_type_name(), " / GDSync host = ", GDSync.is_host())

func get_deck_type_name() -> String:
	if deck_type == DeckType.WORKER:
		return "WORKER"

	if deck_type == DeckType.WARRIOR:
		return "WARRIOR"

	return "UNKNOWN"

func draw_player_card() -> void:
	if phase_manager == null:
		return

	if not phase_manager.is_draw_phase():
		return

	var my_peer_id := int(GDSync.get_client_id())

	if GDSync.is_host():
		_host_resolve_draw(my_peer_id)
	else:
		GDSync.call_func(request_draw_from_host, my_peer_id)

func request_draw_from_host(requesting_peer_id: int) -> void:
	if not GDSync.is_host():
		return

	_host_resolve_draw(requesting_peer_id)

func _host_resolve_draw(drawer_peer_id: int) -> void:
	var data := pick_card_data()
	if data == null:
		return

	var card_id := DeckDrawHandler.next_card_id
	DeckDrawHandler.next_card_id += 1

	GDSync.call_func_all(commit_draw_remote, drawer_peer_id, data.name, card_id)

func commit_draw_remote(drawer_peer_id: int, card_name: String, card_id: int) -> void:
	_commit_draw_local(drawer_peer_id, card_name, card_id)

func spawn_cards_from_effect(owner_peer_id: int, amount: int) -> void:
	if deck_type != DeckType.WORKER:
		print("PregnAnt blocked: this handler is not WORKER, it is ", get_deck_type_name())
		return

	if amount <= 0:
		return

	print("PregnAnt spawning workers through ", get_deck_type_name(), " deck")

	if GDSync.is_host():
		_pregnant_host_spawn_workers(owner_peer_id, amount)
	else:
		GDSync.call_func(pregnant_request_spawn_workers_from_host, owner_peer_id, amount)

func pregnant_request_spawn_workers_from_host(owner_peer_id: int, amount: int) -> void:
	if not GDSync.is_host():
		return

	if deck_type != DeckType.WORKER:
		return

	_pregnant_host_spawn_workers(owner_peer_id, amount)

func _pregnant_host_spawn_workers(owner_peer_id: int, amount: int) -> void:
	if deck_type != DeckType.WORKER:
		return

	for i in range(amount):
		var data := pick_card_data()
		if data == null:
			print("PregnAnt blocked: worker card data missing")
			continue

		var card_id := DeckDrawHandler.next_card_id
		DeckDrawHandler.next_card_id += 1

		print("PregnAnt picked worker card: ", data.name)

		GDSync.call_func_all(pregnant_commit_spawn_worker_card, owner_peer_id, data.name, card_id)

func pregnant_commit_spawn_worker_card(owner_peer_id: int, card_name: String, card_id: int) -> void:
	if deck_type != DeckType.WORKER:
		return

	_commit_draw_local(owner_peer_id, card_name, card_id)

func _commit_draw_local(drawer_peer_id: int, card_name: String, card_id: int) -> bool:
	var target_hand: Node2D = player_hand
	var new_card_owner: int = Card.Owner.PLAYER

	if int(GDSync.get_client_id()) != drawer_peer_id:
		target_hand = opponent_hand
		new_card_owner = Card.Owner.OPPONENT

	return draw_specific_card_to_hand(
		target_hand,
		new_card_owner,
		card_name,
		card_id,
		drawer_peer_id
	)

func draw_specific_card_to_hand(
	target_hand: Node2D,
	new_card_owner: int,
	card_name: String,
	card_id: int,
	owning_peer_id: int
) -> bool:
	if deck == null:
		print("draw blocked: deck is null on ", get_deck_type_name())
		return false

	if target_hand == null:
		print("draw blocked: target_hand is null on ", get_deck_type_name())
		return false

	if card_database == null:
		print("draw blocked: card_database is null on ", get_deck_type_name())
		return false

	if deck.card_scene == null:
		print("draw blocked: deck.card_scene is null on ", get_deck_type_name())
		return false

	if not target_hand.has_method("add_card_to_hand"):
		print("draw blocked: target_hand has no add_card_to_hand")
		return false

	if target_hand.has_method("is_hand_full") and target_hand.is_hand_full():
		print("draw blocked: hand is full")
		return false

	var data := get_card_data_by_name(card_name)

	if data == null:
		print("draw blocked: card data not found for ", card_name, " on ", get_deck_type_name())
		return false

	if not deck.consume_card():
		print("draw blocked: deck is empty on ", get_deck_type_name())
		return false

	var new_card := deck.card_scene.instantiate() as Card

	if new_card == null:
		print("draw blocked: card_scene did not instantiate Card")
		return false

	new_card.multiplayer_card_id = card_id
	new_card.owning_peer_id = owning_peer_id
	new_card.card_owner = new_card_owner
	new_card.player_hand = target_hand
	new_card.combat_manager = combat_manager

	if new_card_owner == Card.Owner.PLAYER:
		new_card.select_handler = select_handler
	else:
		new_card.select_handler = null

	target_hand.add_child(new_card)

	var deck_root := get_parent() as Node2D

	if deck_root != null:
		new_card.global_position = deck_root.global_position

	new_card.setup_card(data)

	target_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)

	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("card_flip")

	print("spawned from ", get_deck_type_name(), " deck: ", new_card.card_name)

	return true

func get_card_data_by_name(card_name: String) -> CardData:
	if card_database == null:
		return null

	for data in card_database.cards:
		if data == null:
			continue

		if data.name == card_name:
			return data

	return null

func pick_card_data() -> CardData:
	if card_database == null:
		return null

	if card_database.cards.is_empty():
		return null

	return card_database.cards[randi() % card_database.cards.size()]

func spawn_effect_card_to_hand(
	owner_peer_id: int,
	card_name: String,
	card_id: int,
	inherited_mutation_paths: Array[String] = []
) -> void:
	var spawned := _commit_draw_local(owner_peer_id, card_name, card_id)

	if not spawned:
		return

	var target_hand: Node2D = player_hand

	if int(GDSync.get_client_id()) != owner_peer_id:
		target_hand = opponent_hand

	if target_hand == null:
		return

	for child in target_hand.get_children():
		var card := child as Card

		if card == null:
			continue

		if card.multiplayer_card_id != card_id:
			continue

		for path in inherited_mutation_paths:
			var mutation := load(path) as Mutation

			if mutation != null:
				card.add_additional_mutation(mutation)

		return
