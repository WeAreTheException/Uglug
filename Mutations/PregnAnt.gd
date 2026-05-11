extends Mutation
class_name PregnAnt

@export var spawn_count: int = 2

func on_death(card: Card) -> void:
	if card == null:
		return

	var worker_draw_handler := find_worker_deck_draw_handler(card)

	if worker_draw_handler == null:
		print("PregnAnt blocked: could not find WORKER DeckDrawHandler")
		return

	worker_draw_handler.spawn_cards_from_effect(card.owning_peer_id, spawn_count)

func find_worker_deck_draw_handler(card: Card) -> DeckDrawHandler:
	var scene := card.get_tree().current_scene

	if scene == null:
		return null

	return find_worker_deck_draw_handler_recursive(scene)

func find_worker_deck_draw_handler_recursive(node: Node) -> DeckDrawHandler:
	var handler := node as DeckDrawHandler

	if handler != null and handler.deck_type == DeckDrawHandler.DeckType.WORKER:
		return handler

	for child in node.get_children():
		var found := find_worker_deck_draw_handler_recursive(child)

		if found != null:
			return found

	return null
