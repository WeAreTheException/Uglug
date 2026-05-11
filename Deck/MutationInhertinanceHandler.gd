extends Node
class_name MutationInhertitanceHandler

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

	for i in range(amount):
		var data := draw_handler.pick_card_data()

		if data == null:
			print("MutationInhertitanceHandler blocked: worker card data missing")
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

	draw_handler.spawn_effect_card_to_hand(
		owner_peer_id,
		card_name,
		card_id,
		inherited_mutation_paths
	)
