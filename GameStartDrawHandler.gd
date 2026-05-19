extends Node
class_name GameStartDrawHandler

@export var worker_deck_path: NodePath = "../Hand&Deck/WorkerDeck/DeckDrawHandler"
@export var warrior_deck_path: NodePath = "../Hand&Deck/WarriorDeck/DeckDrawHandler"
@export var turn_manager_path: NodePath = "../Handlers/TurnManager"

@export var starting_workers: int = 2
@export var starting_warriors: int = 2

var worker_deck: DeckDrawHandler = null
var warrior_deck: DeckDrawHandler = null
var turn_manager: TurnManager = null

var has_given_starting_cards := false


func _ready() -> void:
	worker_deck = get_node_or_null(worker_deck_path) as DeckDrawHandler
	warrior_deck = get_node_or_null(warrior_deck_path) as DeckDrawHandler
	turn_manager = get_node_or_null(turn_manager_path) as TurnManager

	if worker_deck == null:
		print("GameStartDrawHandler blocked: worker_deck not found at ", worker_deck_path)

	if warrior_deck == null:
		print("GameStartDrawHandler blocked: warrior_deck not found at ", warrior_deck_path)

	if turn_manager == null:
		print("GameStartDrawHandler blocked: turn_manager not found at ", turn_manager_path)

	if not GDSync.is_host():
		return

	call_deferred("_wait_for_players_then_draw")


func _wait_for_players_then_draw() -> void:
	if has_given_starting_cards:
		return

	while turn_manager != null:
		if turn_manager.player_one_id != -1 and turn_manager.player_two_id != -1:
			break

		await get_tree().process_frame

	give_starting_cards()


func give_starting_cards() -> void:
	if has_given_starting_cards:
		return

	has_given_starting_cards = true

	if turn_manager == null:
		print("GameStartDrawHandler blocked: turn_manager is null")
		return

	var player_ids: Array[int] = [
		turn_manager.player_one_id,
		turn_manager.player_two_id
	]

	for peer_id in player_ids:
		if peer_id == -1:
			continue

		print("Giving starting cards to peer: ", peer_id)

		if worker_deck != null:
			worker_deck.spawn_cards_from_effect(peer_id, starting_workers)

		if warrior_deck != null:
			warrior_deck.spawn_cards_from_effect(peer_id, starting_warriors)

	print("GAME START DRAW COMPLETE")
