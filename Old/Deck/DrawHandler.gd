extends Node
class_name DeckDrawHandler

enum DeckType {
	WORKER,
	WARRIOR
}

static var next_card_id: int = 1

@export var card_database: CardDatabase
@export var deck_type: DeckType = DeckType.WORKER

var combat_manager: CombatManager = null

var deck: DeckCount = null
var player_hand: Node2D = null
var opponent_hand: Node2D = null
var phase_manager: PhaseManager = null
var select_handler: SelectHandler = null

var worker_union_buff_handler: WorkerUnionBuffHandler = null
var draw_feedback: DeckDrawFeedback = null
var draw_limit_handler: DeckDrawLimitHandler = null
var card_spawn_handler: CardSpawnHandler = null


func _ready() -> void:
	add_to_group("deck_draw_handlers")

	GDSync.expose_node(self)
	GDSync.expose_func(request_draw_from_host)
	GDSync.expose_func(commit_draw_remote)
	GDSync.expose_func(request_spawn_cards_from_host)
	GDSync.expose_func(commit_spawn_card_from_effect)

	_find_child_handlers()

	print("DeckDrawHandler ready / deck_type = ", get_deck_type_name(), " / GDSync host = ", GDSync.is_host())


func _process(_delta: float) -> void:
	_refresh_child_handlers()

	if draw_limit_handler != null:
		draw_limit_handler.process_limit_reset()


func _find_child_handlers() -> void:
	worker_union_buff_handler = get_node_or_null("WorkerUnionBuffHandler") as WorkerUnionBuffHandler
	draw_feedback = get_node_or_null("DeckDrawFeedback") as DeckDrawFeedback
	draw_limit_handler = get_node_or_null("DeckDrawLimitHandler") as DeckDrawLimitHandler
	card_spawn_handler = get_node_or_null("CardSpawnHandler") as CardSpawnHandler


func _refresh_child_handlers() -> void:
	if worker_union_buff_handler == null:
		worker_union_buff_handler = get_node_or_null("WorkerUnionBuffHandler") as WorkerUnionBuffHandler

	if draw_feedback == null:
		draw_feedback = get_node_or_null("DeckDrawFeedback") as DeckDrawFeedback

	if draw_limit_handler == null:
		draw_limit_handler = get_node_or_null("DeckDrawLimitHandler") as DeckDrawLimitHandler

	if card_spawn_handler == null:
		card_spawn_handler = get_node_or_null("CardSpawnHandler") as CardSpawnHandler

	if draw_limit_handler != null:
		draw_limit_handler.phase_manager = phase_manager
		draw_limit_handler.player_hand = player_hand

	if draw_feedback != null:
		draw_feedback.phase_manager = phase_manager
		draw_feedback.draw_limit_handler = draw_limit_handler

	if card_spawn_handler != null:
		card_spawn_handler.card_database = card_database
		card_spawn_handler.deck = deck
		card_spawn_handler.combat_manager = combat_manager
		card_spawn_handler.select_handler = select_handler
		card_spawn_handler.draw_feedback = draw_feedback
		card_spawn_handler.worker_union_buff_handler = worker_union_buff_handler
		card_spawn_handler.deck_type_name = get_deck_type_name()
		card_spawn_handler.should_apply_worker_union_buff = deck_type == DeckType.WORKER


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

	_refresh_child_handlers()

	if draw_limit_handler != null:
		if not draw_limit_handler.can_draw():
			if draw_feedback != null:
				draw_feedback.show_max_draw_limit_message()
			return

		draw_limit_handler.use_draw()

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
	_refresh_child_handlers()

	if card_spawn_handler == null:
		print("draw blocked: CardSpawnHandler missing on ", get_deck_type_name())
		return false

	var deck_root := get_parent() as Node2D

	return card_spawn_handler.spawn_card_to_hand(
		target_hand,
		new_card_owner,
		card_name,
		card_id,
		owning_peer_id,
		deck_root
	)


func pick_card_data() -> CardData:
	if deck == null:
		print("pick_card_data blocked: deck is null on ", get_deck_type_name())
		return null

	if not deck.has_cards():
		print("pick_card_data blocked: deck is empty on ", get_deck_type_name())
		return null

	return deck.draw_card_data()
