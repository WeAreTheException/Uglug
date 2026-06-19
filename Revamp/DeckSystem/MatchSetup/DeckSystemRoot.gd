extends Node
class_name DeckSystemRoot

signal match_decks_built
signal starting_hands_dealt

const DRAW_PILE_WARRIOR := "warrior"
const DRAW_PILE_WORKER := "worker"

@export var match_network_root: MatchNetworkRoot
@export var buff_database: BuffDatabase
@export var player_one_hand: PlayerHandRoot
@export var player_two_hand: PlayerHandRoot
@export var match_setup: MatchDeckSetup
@export var player_one_draw_pile: DrawPileRoot
@export var player_two_draw_pile: DrawPileRoot
@export var worker_source: WorkerSource
@export var build_on_ready: bool = false

@export var animate_starting_hand_deal: bool = true
@export var starting_hand_start_delay: float = 0.25
@export var starting_hand_card_delay: float = 0.12

@export var enable_payload_apply_debug := false
@export var payload_apply_debug_key: Key = KEY_P

var payload_builder := MatchSetupPayloadBuilder.new()
var last_setup_payload: Dictionary = {}
var card_lookup_cache: Dictionary = {}


func _ready() -> void:
	if match_setup != null:
		match_setup.setup(self)

	_setup_hand_contexts()

	if build_on_ready:
		build_match_decks()


func _input(event: InputEvent) -> void:
	if not enable_payload_apply_debug:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == payload_apply_debug_key:
		_apply_payload_debug()


func build_match_decks() -> void:
	if match_setup == null:
		return

	_setup_hand_contexts()

	var result: Dictionary = match_setup.build_match_decks()

	if result.is_empty():
		return

	var p1_draw: Array[CardData] = _to_card_data_array(result["p1_draw_pile"])
	var p2_draw: Array[CardData] = _to_card_data_array(result["p2_draw_pile"])
	var p1_start: Array[CardData] = _to_card_data_array(result["p1_starting_hand"])
	var p2_start: Array[CardData] = _to_card_data_array(result["p2_starting_hand"])

	card_lookup_cache.clear()
	_register_card_data_array(p1_draw)
	_register_card_data_array(p2_draw)
	_register_card_data_array(p1_start)
	_register_card_data_array(p2_start)
	_register_worker_source_card()

	last_setup_payload = payload_builder.build_payload(
		_get_match_seed(),
		p1_start,
		p2_start,
		p1_draw,
		p2_draw
	)

	print("MATCH SETUP PAYLOAD: ", last_setup_payload)

	if player_one_draw_pile != null:
		player_one_draw_pile.setup_with_entries(
			last_setup_payload.get("p1_draw_pile", [])
		)

	if player_two_draw_pile != null:
		player_two_draw_pile.setup_with_entries(
			last_setup_payload.get("p2_draw_pile", [])
		)

	match_decks_built.emit()

	if animate_starting_hand_deal:
		_deal_starting_hands_animated_from_payload()
	else:
		_spawn_payload_hand(
			player_one_hand,
			last_setup_payload.get("p1_starting_hand", [])
		)
		_spawn_payload_hand(
			player_two_hand,
			last_setup_payload.get("p2_starting_hand", [])
		)
		starting_hands_dealt.emit()


func apply_match_setup_payload(payload: Dictionary) -> void:
	_setup_hand_contexts()
	_rebuild_card_lookup_cache_from_setup()
	_clear_match_cards()

	if player_one_draw_pile != null:
		player_one_draw_pile.setup_with_entries(payload.get("p1_draw_pile", []))

	if player_two_draw_pile != null:
		player_two_draw_pile.setup_with_entries(payload.get("p2_draw_pile", []))

	_spawn_payload_hand(player_one_hand, payload.get("p1_starting_hand", []))
	_spawn_payload_hand(player_two_hand, payload.get("p2_starting_hand", []))

	last_setup_payload = payload.duplicate(true)

	match_decks_built.emit()
	starting_hands_dealt.emit()


func get_last_setup_payload() -> Dictionary:
	return last_setup_payload.duplicate(true)


func get_card_data(card_id: String) -> CardData:
	var clean_id := card_id.strip_edges()

	if clean_id == "":
		print("DeckSystemRoot card lookup failed: empty card_id")
		return null

	if card_lookup_cache.has(clean_id):
		return card_lookup_cache[clean_id] as CardData

	_rebuild_card_lookup_cache_from_setup()

	if card_lookup_cache.has(clean_id):
		return card_lookup_cache[clean_id] as CardData

	print("DeckSystemRoot card lookup failed: ", clean_id)
	return null


func get_hand_for_card_owner(source_card: CardRoot) -> PlayerHandRoot:
	return _get_hand_for_card_owner(source_card)


func get_hand_for_owner(owner: SlotRow.SlotOwner) -> PlayerHandRoot:
	if owner == SlotRow.SlotOwner.OPPONENT:
		return player_two_hand

	return player_one_hand


func get_draw_pile_for_owner(owner: SlotRow.SlotOwner) -> DrawPileRoot:
	if owner == SlotRow.SlotOwner.OPPONENT:
		return player_two_draw_pile

	return player_one_draw_pile


func pop_draw_entry_for_owner(
	owner: SlotRow.SlotOwner,
	pile_type: String
) -> Dictionary:
	if pile_type == DRAW_PILE_WORKER:
		return _build_worker_draw_entry(owner)

	var draw_pile := get_draw_pile_for_owner(owner)

	if draw_pile == null:
		return {}

	return draw_pile.draw_card_entry()


func apply_confirmed_draw(
	owner: SlotRow.SlotOwner,
	card_id: String,
	runtime_id: String,
	pile_type: String,
	pop_local_pile: bool,
	inherit_mutation_ids: Array[String] = []
) -> CardRoot:
	if pop_local_pile and pile_type == DRAW_PILE_WARRIOR:
		_pop_and_check_local_draw_pile(owner, card_id, runtime_id)

	var hand := get_hand_for_owner(owner)
	var card_data := get_card_data(card_id)

	if hand == null:
		print("confirmed draw blocked: hand missing")
		return null

	if card_data == null:
		print("confirmed draw blocked: card data missing ", card_id)
		return null

	var card := hand.spawn_card_with_runtime_id(card_data, runtime_id)

	if card != null:
		_apply_inherited_mutations_to_card(card, inherit_mutation_ids)

	return card


func _apply_inherited_mutations_to_card(
	card: CardRoot,
	inherit_mutation_ids: Array[String]
) -> void:
	if card == null:
		return

	if inherit_mutation_ids.is_empty():
		return

	if card.mutations == null:
		return

	for mutation_id in inherit_mutation_ids:
		var mutation := _find_mutation_by_id(mutation_id)

		if mutation == null:
			print("INHERIT MUTATION FAILED: ", mutation_id)
			continue

		card.mutations.add_buff_mutation(mutation)
		
func draw_warrior_for_owner(owner: SlotRow.SlotOwner) -> void:
	var entry := pop_draw_entry_for_owner(owner, DRAW_PILE_WARRIOR)

	if entry.is_empty():
		return

	apply_confirmed_draw(
		owner,
		entry.get("card_id", ""),
		entry.get("runtime_id", ""),
		DRAW_PILE_WARRIOR,
		false
	)


func draw_worker_for_owner(owner: SlotRow.SlotOwner) -> void:
	var entry := pop_draw_entry_for_owner(owner, DRAW_PILE_WORKER)

	if entry.is_empty():
		return

	apply_confirmed_draw(
		owner,
		entry.get("card_id", ""),
		entry.get("runtime_id", ""),
		DRAW_PILE_WORKER,
		false
	)


func draw_warrior_for_player_one() -> void:
	draw_warrior_for_owner(SlotRow.SlotOwner.PLAYER)


func draw_warrior_for_player_two() -> void:
	draw_warrior_for_owner(SlotRow.SlotOwner.OPPONENT)


func draw_worker_for_player_one() -> void:
	draw_worker_for_owner(SlotRow.SlotOwner.PLAYER)


func draw_worker_for_player_two() -> void:
	draw_worker_for_owner(SlotRow.SlotOwner.OPPONENT)


func draw_random_cards_from_effect_for_card_owner(
	source_card: CardRoot,
	amount: int,
	respect_hand_limit: bool = false
) -> Array[CardRoot]:
	var drawn_cards: Array[CardRoot] = []

	if source_card == null or not is_instance_valid(source_card):
		return drawn_cards

	if amount <= 0:
		return drawn_cards

	var owner := _get_owner_for_card(source_card)
	var inherit_mutation_ids := _get_inheritable_mutation_ids(source_card)

	if match_network_root != null:
		if not match_network_root.is_host():
			return drawn_cards

		for i: int in range(amount):
			match_network_root.request_draw(
				owner,
				DRAW_PILE_WARRIOR,
				inherit_mutation_ids
			)

		return drawn_cards

	for i: int in range(amount):
		var entry := pop_draw_entry_for_owner(owner, DRAW_PILE_WARRIOR)

		if entry.is_empty():
			break

		var spawned_card := apply_confirmed_draw(
			owner,
			entry.get("card_id", ""),
			entry.get("runtime_id", ""),
			DRAW_PILE_WARRIOR,
			false,
			inherit_mutation_ids
		)

		if spawned_card != null:
			drawn_cards.append(spawned_card)

	return drawn_cards


func spawn_workers_from_effect_for_card_owner(
	source_card: CardRoot,
	amount: int,
	respect_hand_limit: bool = false
) -> Array[CardRoot]:
	var spawned_cards: Array[CardRoot] = []

	if source_card == null or not is_instance_valid(source_card):
		return spawned_cards

	if amount <= 0:
		return spawned_cards

	var owner := _get_owner_for_card(source_card)
	var inherit_mutation_ids := _get_inheritable_mutation_ids(source_card)

	if match_network_root != null:
		if not match_network_root.is_host():
			return spawned_cards

		for i: int in range(amount):
			match_network_root.request_draw(
				owner,
				DRAW_PILE_WORKER,
				inherit_mutation_ids
			)

		return spawned_cards

	for i: int in range(amount):
		var entry := pop_draw_entry_for_owner(owner, DRAW_PILE_WORKER)

		if entry.is_empty():
			break

		var spawned_card := apply_confirmed_draw(
			owner,
			entry.get("card_id", ""),
			entry.get("runtime_id", ""),
			DRAW_PILE_WORKER,
			false,
			inherit_mutation_ids
		)

		if spawned_card != null:
			spawned_cards.append(spawned_card)

	return spawned_cards

func _apply_inherited_mutations_to_entry(
	entry: Dictionary,
	inherit_mutation_ids: Array[String]
) -> void:
	if entry.is_empty():
		return

	if inherit_mutation_ids.is_empty():
		entry["inherited_mutation_ids"] = []
		return

	entry["inherited_mutation_ids"] = inherit_mutation_ids.duplicate()

func find_card_anywhere(runtime_id: String) -> CardRoot:
	var clean_id := runtime_id.strip_edges()

	if clean_id == "":
		return null

	var card := _find_card_in_hand(player_one_hand, clean_id)

	if card != null:
		return card

	card = _find_card_in_hand(player_two_hand, clean_id)

	if card != null:
		return card

	return null


func _deal_starting_hands_animated_from_payload() -> void:
	await get_tree().create_timer(starting_hand_start_delay).timeout

	var p1_entries: Array = last_setup_payload.get("p1_starting_hand", [])
	var p2_entries: Array = last_setup_payload.get("p2_starting_hand", [])
	var max_count: int = max(p1_entries.size(), p2_entries.size())

	for i: int in range(max_count):
		if i < p1_entries.size():
			_spawn_payload_card(player_one_hand, p1_entries[i])

		if i < p2_entries.size():
			_spawn_payload_card(player_two_hand, p2_entries[i])

		await get_tree().create_timer(starting_hand_card_delay).timeout

	starting_hands_dealt.emit()


func _spawn_payload_hand(hand: PlayerHandRoot, entries: Array) -> void:
	if hand == null:
		return

	for entry in entries:
		_spawn_payload_card(hand, entry)

	hand.arrange_cards()


func _spawn_payload_card(hand: PlayerHandRoot, entry) -> CardRoot:
	if hand == null:
		return null

	if not entry is Dictionary:
		return null

	var card_id: String = entry.get("card_id", "")
	var runtime_id: String = entry.get("runtime_id", "")
	var card_data := get_card_data(card_id)

	if card_data == null:
		return null

	return hand.spawn_card_with_runtime_id(card_data, runtime_id)


func _clear_match_cards() -> void:
	if player_one_hand != null:
		player_one_hand.clear_cards(true)

	if player_two_hand != null:
		player_two_hand.clear_cards(true)

	if player_one_draw_pile != null:
		player_one_draw_pile.clear_cards()

	if player_two_draw_pile != null:
		player_two_draw_pile.clear_cards()


func _build_worker_draw_entry(owner: SlotRow.SlotOwner) -> Dictionary:
	if worker_source == null:
		print("worker draw blocked: worker_source missing")
		return {}

	var worker := worker_source.get_worker_card()

	if worker == null:
		print("worker draw blocked: worker card missing")
		return {}

	_register_card_data(worker)

	return {
		"card_id": worker.get_safe_card_id(),
		"runtime_id": _build_runtime_id(owner, DRAW_PILE_WORKER, worker)
	}


func _pop_and_check_local_draw_pile(
	owner: SlotRow.SlotOwner,
	card_id: String,
	runtime_id: String
) -> void:
	var draw_pile := get_draw_pile_for_owner(owner)

	if draw_pile == null:
		return

	var local_entry := draw_pile.draw_card_entry()

	if local_entry.is_empty():
		print("confirmed draw warning: local draw pile empty")
		return

	if local_entry.get("card_id", "") != card_id:
		print("confirmed draw warning: card_id mismatch")

	if local_entry.get("runtime_id", "") != runtime_id:
		print("confirmed draw warning: runtime_id mismatch")


func _setup_hand_contexts() -> void:
	if player_one_hand != null:
		player_one_hand.setup_deck_system_context(self)

	if player_two_hand != null:
		player_two_hand.setup_deck_system_context(self)


func _get_hand_for_card_owner(source_card: CardRoot) -> PlayerHandRoot:
	var owner: SlotRow.SlotOwner = _get_owner_for_card(source_card)

	return get_hand_for_owner(owner)


func _get_owner_for_card(source_card: CardRoot) -> SlotRow.SlotOwner:
	if source_card == null:
		return SlotRow.SlotOwner.PLAYER

	if source_card.slots_root != null:
		var slot: Slot = source_card.get_current_slot()

		if slot != null:
			return source_card.slots_root.get_owner_of_slot(slot)

	if player_two_hand != null and player_two_hand.has_card(source_card):
		return SlotRow.SlotOwner.OPPONENT

	if player_one_hand != null and player_one_hand.has_card(source_card):
		return SlotRow.SlotOwner.PLAYER

	return SlotRow.SlotOwner.PLAYER


func _get_match_seed() -> int:
	if match_setup == null:
		return 0

	if match_setup.seed_config == null:
		return 12345

	return match_setup.seed_config.get_seed()


func _to_card_data_array(source: Array) -> Array[CardData]:
	var result: Array[CardData] = []

	for item in source:
		var card_data: CardData = item as CardData

		if card_data != null:
			result.append(card_data)

	return result


func _find_card_in_hand(
	hand: PlayerHandRoot,
	runtime_id: String
) -> CardRoot:
	if hand == null:
		return null

	return hand.find_card_by_runtime_id(runtime_id)


func _build_runtime_id(
	owner: SlotRow.SlotOwner,
	pile_type: String,
	card_data: CardData
) -> String:
	var owner_prefix := "p1"

	if owner == SlotRow.SlotOwner.OPPONENT:
		owner_prefix = "p2"

	return (
		owner_prefix
		+ "_"
		+ pile_type
		+ "_"
		+ card_data.get_safe_card_id()
		+ "_"
		+ str(Time.get_ticks_usec())
	)


func _rebuild_card_lookup_cache_from_setup() -> void:
	if match_setup == null:
		return

	var result: Dictionary = match_setup.build_match_decks()

	if result.is_empty():
		return

	card_lookup_cache.clear()

	_register_card_data_array(_to_card_data_array(result.get("p1_draw_pile", [])))
	_register_card_data_array(_to_card_data_array(result.get("p2_draw_pile", [])))
	_register_card_data_array(_to_card_data_array(result.get("p1_starting_hand", [])))
	_register_card_data_array(_to_card_data_array(result.get("p2_starting_hand", [])))
	_register_worker_source_card()


func _register_card_data_array(cards: Array[CardData]) -> void:
	for card_data: CardData in cards:
		_register_card_data(card_data)


func _register_card_data(card_data: CardData) -> void:
	if card_data == null:
		return

	var safe_id := card_data.get_safe_card_id().strip_edges()

	if safe_id != "":
		card_lookup_cache[safe_id] = card_data

	var explicit_id := card_data.card_id.strip_edges()

	if explicit_id != "":
		card_lookup_cache[explicit_id] = card_data


func _register_worker_source_card() -> void:
	if worker_source == null:
		return

	var worker := worker_source.get_worker_card()

	if worker == null:
		return

	_register_card_data(worker)


func _apply_payload_debug() -> void:
	if last_setup_payload.is_empty():
		print("PAYLOAD APPLY DEBUG FAILED: no payload")
		return

	print("PAYLOAD APPLY DEBUG: applying last setup payload")
	apply_match_setup_payload(last_setup_payload)

func _get_inheritable_mutation_ids(source_card: CardRoot) -> Array[String]:
	var ids: Array[String] = []

	if source_card == null:
		return ids

	if not is_instance_valid(source_card):
		return ids

	if source_card.mutations == null:
		return ids

	for mutation in source_card.mutations.get_inheritable_mutations():
		if mutation == null:
			continue

		var id := mutation.get_safe_mutation_id()

		if id.strip_edges() != "":
			ids.append(id)

	return ids

func _find_mutation_by_id(mutation_id: String) -> Mutation:
	var clean_id := mutation_id.strip_edges()

	if clean_id == "":
		return null

	if buff_database == null:
		print("INHERIT MUTATION FAILED: buff_database missing")
		return null

	return buff_database.get_mutation_by_id(clean_id)
