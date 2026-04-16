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
@export var select_handler: SelectHandler
@export var worker_draw_handler: DeckDrawHandler

var deck: DeckCount = null
var player_hand: Node2D = null
var opponent_hand: Node2D = null
var card_manager: Node2D = null
var spawn_anchor: Node2D = null
var opponent_spawn_anchor: Node2D = null
var phase_manager: PhaseManager = null
var battle_scale: BattleScale = null

func _ready() -> void:
	if deck_type == DeckType.WORKER and worker_draw_handler == null:
		worker_draw_handler = self

func draw_player_card() -> void:
	if phase_manager == null:
		print("Draw blocked: phase_manager is null")
		return

	if not phase_manager.is_player_draw_phase():
		print("Draw blocked: not in PLAYER_DRAW phase")
		return

	if deck_type == DeckType.WORKER:
		if not phase_manager.can_draw_worker_card():
			print("Draw blocked: worker draw not allowed")
			return
	elif deck_type == DeckType.WARRIOR:
		if not phase_manager.can_draw_warrior_card():
			print("Draw blocked: warrior draw not allowed")
			return

	if multiplayer.multiplayer_peer == null:
		var local_data := pick_card_data()
		if local_data == null:
			return

		var local_card_id := DeckDrawHandler.next_card_id
		DeckDrawHandler.next_card_id += 1

		var local_success := draw_specific_card_to_hand(
			player_hand,
			spawn_anchor,
			Card.Owner.PLAYER,
			local_data.name,
			local_card_id
		)
		if not local_success:
			return

		_on_local_draw_confirmed()
		return

	if multiplayer.is_server():
		_host_resolve_draw(multiplayer.get_unique_id())
	else:
		rpc_id(1, "request_draw_from_host")

@rpc("any_peer", "call_remote", "reliable")
func request_draw_from_host() -> void:
	if not multiplayer.is_server():
		return

	var requesting_peer_id := multiplayer.get_remote_sender_id()
	_host_resolve_draw(requesting_peer_id)

func _host_resolve_draw(drawer_peer_id: int) -> void:
	var data := pick_card_data()
	if data == null:
		print("Draw failed: no card data available")
		return

	var card_id := DeckDrawHandler.next_card_id
	DeckDrawHandler.next_card_id += 1

	var local_success := _commit_draw_local(drawer_peer_id, data.name, card_id)
	if not local_success:
		print("Draw failed: host local commit failed")
		return

	rpc("commit_draw_remote", drawer_peer_id, data.name, card_id)

	if drawer_peer_id == multiplayer.get_unique_id():
		_on_local_draw_confirmed()

@rpc("authority", "call_remote", "reliable")
func commit_draw_remote(drawer_peer_id: int, card_name: String, card_id: int) -> void:
	var success := _commit_draw_local(drawer_peer_id, card_name, card_id)
	if not success:
		print("Remote draw commit failed for ", card_name)
		return

	if multiplayer.get_unique_id() == drawer_peer_id:
		_on_local_draw_confirmed()

func _commit_draw_local(drawer_peer_id: int, card_name: String, card_id: int) -> bool:
	var target_hand: Node2D = null
	var target_spawn_anchor: Node2D = null
	var card_owner: int = Card.Owner.PLAYER

	if multiplayer.get_unique_id() == drawer_peer_id:
		target_hand = player_hand
		target_spawn_anchor = spawn_anchor
		card_owner = Card.Owner.PLAYER
	else:
		target_hand = opponent_hand
		target_spawn_anchor = opponent_spawn_anchor
		card_owner = Card.Owner.OPPONENT

	if target_spawn_anchor == null and target_hand != null:
		target_spawn_anchor = target_hand

	return draw_specific_card_to_hand(target_hand, target_spawn_anchor, card_owner, card_name, card_id)

func _on_local_draw_confirmed() -> void:
	if phase_manager == null:
		return

	if deck_type == DeckType.WORKER:
		phase_manager.on_player_drew_worker_card()
	elif deck_type == DeckType.WARRIOR:
		phase_manager.on_player_drew_warrior_card()

func draw_card_to_hand(target_hand: Node2D, target_spawn_anchor: Node2D, card_owner: int) -> bool:
	var data: CardData = pick_card_data()
	if data == null:
		return false

	var card_id := DeckDrawHandler.next_card_id
	DeckDrawHandler.next_card_id += 1

	return draw_specific_card_to_hand(target_hand, target_spawn_anchor, card_owner, data.name, card_id)

func draw_specific_card_to_hand(
	target_hand: Node2D,
	target_spawn_anchor: Node2D,
	card_owner: int,
	card_name: String,
	card_id: int
) -> bool:
	if deck == null:
		return false
	if target_hand == null:
		return false
	if card_manager == null:
		return false
	if target_spawn_anchor == null:
		return false
	if card_database == null:
		return false
	if deck.card_scene == null:
		return false

	if target_hand.is_hand_full():
		print("Hand full. Cannot draw.")
		return false

	var data := get_card_data_by_name(card_name)
	if data == null:
		print("Draw failed: no card data found for ", card_name)
		return false

	if not deck.consume_card():
		print("Draw failed: deck empty")
		return false

	var new_card := deck.card_scene.instantiate() as Card
	if new_card == null:
		print("Draw failed: could not instantiate card")
		return false

	new_card.multiplayer_card_id = card_id
	new_card.player_hand = target_hand
	new_card.card_owner = card_owner
	new_card.battle_scale = battle_scale
	new_card.select_handler = select_handler
	new_card.card_scene = deck.card_scene
	new_card.worker_draw_handler = worker_draw_handler

	if new_card.select_handler != null:
		new_card.select_handler.phase_manager = phase_manager

	card_manager.add_child(new_card)
	new_card.global_position = target_spawn_anchor.global_position

	new_card.setup_card(data)

	target_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)

	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("card_flip")

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
