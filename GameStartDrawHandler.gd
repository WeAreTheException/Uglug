extends Node
class_name GameStartDrawHandler

@export var worker_deck_path: NodePath = "../Hand&Deck/WorkerDeck/DeckDrawHandler"
@export var warrior_deck_path: NodePath = "../Hand&Deck/WarriorDeck/DeckDrawHandler"
@export var turn_manager_path: NodePath = "../Handlers/TurnManager"

@export var starting_workers: int = 2
@export var starting_warriors: int = 2

var worker_deck: DeckDrawHandler = null
var warrior_deck: DeckDrawHandler = null
var turn_manager: Node = null

var has_given_starting_cards := false


func _ready() -> void:
	worker_deck = get_node_or_null(worker_deck_path) as DeckDrawHandler
	warrior_deck = get_node_or_null(warrior_deck_path) as DeckDrawHandler
	turn_manager = get_node_or_null(turn_manager_path)

	print("GameStartDrawHandler worker_deck = ", worker_deck)
	print("GameStartDrawHandler warrior_deck = ", warrior_deck)
	print("GameStartDrawHandler turn_manager = ", turn_manager)


func give_starting_cards() -> void:
	if has_given_starting_cards:
		return

	has_given_starting_cards = true

	if not GDSync.is_host():
		return

	if turn_manager == null:
		print("starting draw blocked: turn_manager is null")
		return

	var player_ids: Array[int] = [
	int(turn_manager.get("player_one_id")),
	int(turn_manager.get("player_two_id"))
]

	for peer_id in player_ids:
		if peer_id == -1:
			print("starting draw blocked: invalid peer id")
			continue

		print("Giving starting cards to peer: ", peer_id)

		if worker_deck != null:
			worker_deck.spawn_cards_from_effect(peer_id, starting_workers)

		if warrior_deck != null:
			warrior_deck.spawn_cards_from_effect(peer_id, starting_warriors)

	print("GAME START DRAW COMPLETE")
