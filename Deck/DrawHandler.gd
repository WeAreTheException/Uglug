extends Node
class_name DeckDrawHandler

enum DeckType {
	WORKER,
	WARRIOR
}

static var next_card_id: int = 1

static var shared_draws_used_this_turn: int = 0
static var shared_draw_limit_this_turn: int = 2
static var shared_was_in_draw_phase := false

@export var card_database: CardDatabase
@export var deck_type: DeckType = DeckType.WORKER

@export var normal_draw_limit: int = 2
@export var empty_hand_draw_limit: int = 3

var combat_manager: CombatManager = null

var deck: DeckCount = null
var player_hand: Node2D = null
var opponent_hand: Node2D = null
var phase_manager: PhaseManager = null
var select_handler: SelectHandler = null

var worker_union_buff_handler: WorkerUnionBuffHandler = null
var draw_animation_handler: DeckDrawAnimationHandler = null


func _ready() -> void:
	add_to_group("deck_draw_handlers")

	GDSync.expose_node(self)
	GDSync.expose_func(request_draw_from_host)
	GDSync.expose_func(commit_draw_remote)
	GDSync.expose_func(request_spawn_cards_from_host)
	GDSync.expose_func(commit_spawn_card_from_effect)

	worker_union_buff_handler = get_node_or_null("WorkerUnionBuffHandler") as WorkerUnionBuffHandler
	draw_animation_handler = get_node_or_null("DeckDrawAnimationHandler") as DeckDrawAnimationHandler

	print("DeckDrawHandler ready / deck_type = ", get_deck_type_name(), " / GDSync host = ", GDSync.is_host())


func _process(_delta: float) -> void:
	_check_draw_phase_reset()


func get_deck_type_name() -> String:
	match deck_type:
		DeckType.WORKER:
			return "WORKER"
		DeckType.WARRIOR:
			return "WARRIOR"

	return "UNKNOWN"


func draw_player_card() -> void:
	if phase_manager == null:
		print("draw blocked: phase_manager is null")
		return

	if not phase_manager.is_draw_phase():
		print("draw blocked: not draw phase")
		return

	_check_draw_phase_reset()

	if DeckDrawHandler.shared_draws_used_this_turn >= DeckDrawHandler.shared_draw_limit_this_turn:
		print("draw blocked: max draws this turn")
		return

	var my_peer_id := int(GDSync.get_client_id())

	DeckDrawHandler.shared_draws_used_this_turn += 1

	print(
		"draw used: ",
		DeckDrawHandler.shared_draws_used_this_turn,
		"/",
		DeckDrawHandler.shared_draw_limit_this_turn
	)

	if GDSync.is_host():
		_host_resolve_draw(my_peer_id)
	else:
		GDSync.call_func(request_draw_from_host, my_peer_id)


func _check_draw_phase_reset() -> void:
	if phase_manager == null:
		return

	if phase_manager.is_draw_phase() and not DeckDrawHandler.shared_was_in_draw_phase:
		DeckDrawHandler.shared_was_in_draw_phase = true
		DeckDrawHandler.shared_draws_used_this_turn = 0

		if player_hand != null and player_hand.has_method("get_hand_size"):
			if int(player_hand.get_hand_size()) == 0:
				DeckDrawHandler.shared_draw_limit_this_turn = empty_hand_draw_limit
			else:
				DeckDrawHandler.shared_draw_limit_this_turn = normal_draw_limit
		else:
			DeckDrawHandler.shared_draw_limit_this_turn = normal_draw_limit

		print("shared draw limit this turn: ", DeckDrawHandler.shared_draw_limit_this_turn)

	elif not phase_manager.is_draw_phase():
		DeckDrawHandler.shared_was_in_draw_phase = false


func request_draw_from_host(requesting_peer_id: int) -> void:
	if not GDSync.is_host():
		return

	_host_resolve_draw(requesting_peer_id)


func _host_resolve_draw(drawer_peer_id: int) -> void:
	_host_spawn_cards(drawer_peer_id, 1, commit_draw_remote)


func commit_draw_remote(
	drawer_peer_id: int,
	card_name: String,
	card_id: int
) -> void:
	if not GDSync.is_host():
		if deck != null:
			deck.remove_card_by_name(card_name)

	_commit_draw_local(drawer_peer_id, card_name, card_id)


func spawn_cards_from_effect(owner_peer_id: int, amount: int) -> void:
	if amount <= 0:
		return

	if GDSync.is_host():
		_host_spawn_cards_from_effect(owner_peer_id, amount)
	else:
		GDSync.call_func(request_spawn_cards_from_host, owner_peer_id, amount)


func request_spawn_cards_from_host(owner_peer_id: int, amount: int) -> void:
	if not GDSync.is_host():
		return

	_host_spawn_cards_from_effect(owner_peer_id, amount)


func _host_spawn_cards_from_effect(owner_peer_id: int, amount: int) -> void:
	_host_spawn_cards(owner_peer_id, amount, commit_spawn_card_from_effect)


func _host_spawn_cards(owner_peer_id: int, amount: int, commit_func: Callable) -> void:
	for i in range(amount):
		var data := pick_card_data()

		if data == null:
			print("spawn blocked: no card data from ", get_deck_type_name(), " deck")
			continue

		var card_id := DeckDrawHandler.next_card_id
		DeckDrawHandler.next_card_id += 1

		GDSync.call_func_all(
			commit_func,
			owner_peer_id,
			data.name,
			card_id
		)


func commit_spawn_card_from_effect(
	owner_peer_id: int,
	card_name: String,
	card_id: int
) -> void:
	if not GDSync.is_host():
		if deck != null:
			deck.remove_card_by_name(card_name)

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
		print("draw blocked: target_hand missing add_card_to_hand on ", get_deck_type_name())
		return false

	if target_hand.has_method("is_hand_full") and target_hand.is_hand_full():
		print("draw blocked: hand is full on ", get_deck_type_name())
		return false

	var data := get_card_data_by_name(card_name)

	if data == null:
		print("draw blocked: could not find card data named ", card_name, " in ", get_deck_type_name())
		return false

	var new_card := deck.card_scene.instantiate() as Card

	if new_card == null:
		print("draw blocked: card_scene did not instantiate Card on ", get_deck_type_name())
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

	if draw_animation_handler != null:
		draw_animation_handler.prepare_card_start_position(new_card, deck_root)
	elif deck_root != null:
		new_card.global_position = deck_root.global_position

	new_card.setup_card(data)

	if deck_type == DeckType.WORKER and worker_union_buff_handler != null:
		worker_union_buff_handler.try_apply_to_card(new_card)

	if draw_animation_handler != null:
		draw_animation_handler.add_card_to_hand_with_animation(target_hand, new_card)
		draw_animation_handler.play_draw_animation(new_card)
	else:
		target_hand.add_card_to_hand(new_card)

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
	if deck == null:
		print("pick_card_data blocked: deck is null on ", get_deck_type_name())
		return null

	if not deck.has_cards():
		print("pick_card_data blocked: deck is empty on ", get_deck_type_name())
		return null

	return deck.draw_card_data()
