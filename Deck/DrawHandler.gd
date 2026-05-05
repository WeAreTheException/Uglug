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

var deck: DeckCount = null
var player_hand: Node2D = null
var opponent_hand: Node2D = null
var phase_manager: PhaseManager = null

func draw_player_card() -> void:
	if phase_manager == null:
		return

	if not phase_manager.is_draw_phase():
		return

	var local_peer_id := multiplayer.get_unique_id()

	if multiplayer.multiplayer_peer == null or multiplayer.get_peers().is_empty():
		_draw_local_card(local_peer_id)
		return

	if multiplayer.is_server():
		_host_resolve_draw(local_peer_id)
	else:
		rpc_id(1, "request_draw_from_host")

func _draw_local_card(drawer_peer_id: int) -> void:
	var data := pick_card_data()
	if data == null:
		return

	var card_id := DeckDrawHandler.next_card_id
	DeckDrawHandler.next_card_id += 1

	_commit_draw_local(drawer_peer_id, data.name, card_id)

@rpc("any_peer", "call_remote", "reliable")
func request_draw_from_host() -> void:
	if not multiplayer.is_server():
		return

	var requesting_peer_id := multiplayer.get_remote_sender_id()
	_host_resolve_draw(requesting_peer_id)

func _host_resolve_draw(drawer_peer_id: int) -> void:
	var data := pick_card_data()
	if data == null:
		return

	var card_id := DeckDrawHandler.next_card_id
	DeckDrawHandler.next_card_id += 1

	var success := _commit_draw_local(drawer_peer_id, data.name, card_id)
	if not success:
		return

	rpc("commit_draw_remote", drawer_peer_id, data.name, card_id)

@rpc("authority", "call_remote", "reliable")
func commit_draw_remote(drawer_peer_id: int, card_name: String, card_id: int) -> void:
	_commit_draw_local(drawer_peer_id, card_name, card_id)

func _commit_draw_local(drawer_peer_id: int, card_name: String, card_id: int) -> bool:
	var target_hand: Node2D = player_hand
	var card_owner: int = Card.Owner.PLAYER

	if multiplayer.multiplayer_peer != null:
		if multiplayer.get_unique_id() != drawer_peer_id:
			target_hand = opponent_hand
			card_owner = Card.Owner.OPPONENT

	return draw_specific_card_to_hand(target_hand, card_owner, card_name, card_id)

func draw_specific_card_to_hand(
	target_hand: Node2D,
	card_owner: int,
	card_name: String,
	card_id: int
) -> bool:
	if deck == null:
		return false
	if target_hand == null:
		return false
	if card_database == null:
		return false
	if deck.card_scene == null:
		return false
	if not target_hand.has_method("add_card_to_hand"):
		return false
	if target_hand.has_method("is_hand_full") and target_hand.is_hand_full():
		return false

	var data := get_card_data_by_name(card_name)
	if data == null:
		return false

	if not deck.consume_card():
		return false

	var new_card := deck.card_scene.instantiate() as Card
	if new_card == null:
		return false

	new_card.multiplayer_card_id = card_id
	new_card.card_owner = card_owner
	new_card.player_hand = target_hand

	target_hand.add_child(new_card)

	var deck_root := get_parent() as Node2D
	if deck_root != null:
		new_card.global_position = deck_root.global_position

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
