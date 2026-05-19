extends Node
class_name GameStartDrawHandler

@export var worker_deck_path: NodePath 
@export var warrior_deck_path: NodePath

@export var starting_workers: int = 2
@export var starting_warriors: int = 2

@export var player_peer_ids: Array[int] = [1, 2]

var worker_deck: DeckDrawHandler = null
var warrior_deck: DeckDrawHandler = null
var has_given_starting_cards := false


func _ready() -> void:
	worker_deck = get_node_or_null(worker_deck_path) as DeckDrawHandler
	warrior_deck = get_node_or_null(warrior_deck_path) as DeckDrawHandler

	if worker_deck == null:
		print("GameStartDrawHandler blocked: worker_deck not found at ", worker_deck_path)

	if warrior_deck == null:
		print("GameStartDrawHandler blocked: warrior_deck not found at ", warrior_deck_path)

	if not GDSync.is_host():
		return

	call_deferred("give_starting_cards")


func give_starting_cards() -> void:
	if has_given_starting_cards:
		return

	has_given_starting_cards = true

	for peer_id in player_peer_ids:
		if worker_deck != null:
			worker_deck.spawn_cards_from_effect(peer_id, starting_workers)

		if warrior_deck != null:
			warrior_deck.spawn_cards_from_effect(peer_id, starting_warriors)

	print("GAME START DRAW COMPLETE")
