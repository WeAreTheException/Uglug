extends Node
class_name GameStartDrawHandler

@export var starting_workers: int = 2
@export var starting_warriors: int = 2

var worker_deck: DeckDrawHandler = null
var warrior_deck: DeckDrawHandler = null
var has_given_starting_cards := false


func _ready() -> void:
	call_deferred("_find_decks")


func _find_decks() -> void:
	var all_draw_handlers := get_tree().get_nodes_in_group("deck_draw_handlers")

	for node in all_draw_handlers:
		var draw_handler := node as DeckDrawHandler
		if draw_handler == null:
			continue

		if draw_handler.deck_type == DeckDrawHandler.DeckType.WORKER:
			worker_deck = draw_handler

		if draw_handler.deck_type == DeckDrawHandler.DeckType.WARRIOR:
			warrior_deck = draw_handler

	print("GameStartDrawHandler worker_deck = ", worker_deck)
	print("GameStartDrawHandler warrior_deck = ", warrior_deck)


func give_starting_cards(player_one_id: int, player_two_id: int) -> void:
	if has_given_starting_cards:
		return

	if not GDSync.is_host():
		return

	has_given_starting_cards = true

	await get_tree().process_frame
	await get_tree().process_frame

	if worker_deck == null or warrior_deck == null:
		_find_decks()

	if worker_deck == null:
		print("starting draw blocked: worker_deck is null")
		return

	if warrior_deck == null:
		print("starting draw blocked: warrior_deck is null")
		return

	var player_ids: Array[int] = [player_one_id, player_two_id]

	for peer_id in player_ids:
		print("Giving starting cards to peer: ", peer_id)

		worker_deck.spawn_cards_from_effect(peer_id, starting_workers)
		warrior_deck.spawn_cards_from_effect(peer_id, starting_warriors)

	print("GAME START DRAW COMPLETE")
