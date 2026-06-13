extends Node
class_name MutationInheritanceHandler

var draw_handler: DeckDrawHandler = null


func _ready() -> void:
	draw_handler = get_parent() as DeckDrawHandler

	GDSync.expose_node(self)
	GDSync.expose_func(request_spawn_workers_from_host)
	GDSync.expose_func(commit_spawn_worker_card)


func spawn_workers_with_mutations(
	owner_peer_id: int,
	amount: int,
	inherited_mutation_paths: Array[String]
) -> void:
	if draw_handler == null:
		print("MutationInhertitanceHandler blocked: draw_handler is null")
		return

	if draw_handler.deck_type != DeckDrawHandler.DeckType.WORKER:
		print("MutationInhertitanceHandler blocked: parent draw_handler is not WORKER")
		return

	if amount <= 0:
		return

	if GDSync.is_host():
		_host_spawn_workers(owner_peer_id, amount, inherited_mutation_paths)
	else:
		GDSync.call_func(
			request_spawn_workers_from_host,
			owner_peer_id,
			amount,
			inherited_mutation_paths
		)


func request_spawn_workers_from_host(
	owner_peer_id: int,
	amount: int,
	inherited_mutation_paths: Array[String]
) -> void:
	if not GDSync.is_host():
		return

	_host_spawn_workers(owner_peer_id, amount, inherited_mutation_paths)


func _host_spawn_workers(
	owner_peer_id: int,
	amount: int,
	inherited_mutation_paths: Array[String]
) -> void:
	if draw_handler == null:
		return

	if draw_handler.deck == null:
		print("MutationInhertitanceHandler blocked: draw_handler.deck is null")
		return

	for i in range(amount):
		var data: CardData = draw_handler.deck.draw_card_data()

		if data == null:
			print("MutationInhertitanceHandler blocked: worker real deck empty")
			continue

		var card_id: int = DeckDrawHandler.next_card_id
		DeckDrawHandler.next_card_id += 1

		GDSync.call_func_all(
			commit_spawn_worker_card,
			owner_peer_id,
			data.name,
			card_id,
			inherited_mutation_paths
		)


func commit_spawn_worker_card(
	owner_peer_id: int,
	card_name: String,
	card_id: int,
	inherited_mutation_paths: Array[String]
) -> void:
	if draw_handler == null:
		return

	var target_hand: Node2D = draw_handler.player_hand
	var new_card_owner: int = Card.Owner.PLAYER

	if int(GDSync.get_client_id()) != owner_peer_id:
		target_hand = draw_handler.opponent_hand
		new_card_owner = Card.Owner.OPPONENT

	var success := draw_handler.draw_specific_card_to_hand(
		target_hand,
		new_card_owner,
		card_name,
		card_id,
		owner_peer_id
	)

	if not success:
		return

	var spawned_card: Card = null

	for child in target_hand.get_children():
		if child is Card:
			var card := child as Card

			if card.multiplayer_card_id == card_id:
				spawned_card = card
				break

	if spawned_card == null:
		print("MutationInhertitanceHandler blocked: could not find spawned card")
		return

	for mutation_path in inherited_mutation_paths:
		var inherited_mutation := load(mutation_path) as Mutation

		if inherited_mutation == null:
			print("MutationInhertitanceHandler skipped invalid mutation path: ", mutation_path)
			continue

		spawned_card.add_additional_mutation(inherited_mutation)
