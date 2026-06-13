extends Node
class_name DeckSystemRoot

signal match_decks_built
signal starting_hands_dealt

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


func _ready() -> void:
	if match_setup != null:
		match_setup.setup(self)

	_setup_hand_contexts()

	if build_on_ready:
		build_match_decks()


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

	if player_one_draw_pile != null:
		player_one_draw_pile.setup_with_cards(p1_draw)

	if player_two_draw_pile != null:
		player_two_draw_pile.setup_with_cards(p2_draw)

	match_decks_built.emit()

	if animate_starting_hand_deal:
		_deal_starting_hands_animated(p1_start, p2_start)
	else:
		_deal_starting_hand(player_one_hand, p1_start)
		_deal_starting_hand(player_two_hand, p2_start)
		starting_hands_dealt.emit()


func draw_warrior_for_owner(owner: SlotRow.SlotOwner) -> void:
	if owner == SlotRow.SlotOwner.OPPONENT:
		draw_warrior_for_player_two()
		return

	draw_warrior_for_player_one()


func draw_worker_for_owner(owner: SlotRow.SlotOwner) -> void:
	if owner == SlotRow.SlotOwner.OPPONENT:
		draw_worker_for_player_two()
		return

	draw_worker_for_player_one()


func draw_warrior_for_player_one() -> void:
	_draw_to_hand(player_one_draw_pile, player_one_hand)


func draw_warrior_for_player_two() -> void:
	_draw_to_hand(player_two_draw_pile, player_two_hand)


func draw_worker_for_player_one() -> void:
	_spawn_worker_to_hand(player_one_hand)


func draw_worker_for_player_two() -> void:
	_spawn_worker_to_hand(player_two_hand)


func spawn_workers_from_effect_for_card_owner(
	source_card: CardRoot,
	amount: int,
	respect_hand_limit: bool = false
) -> Array[CardRoot]:
	var spawned_cards: Array[CardRoot] = []

	if source_card == null:
		return spawned_cards

	if not is_instance_valid(source_card):
		return spawned_cards

	if amount <= 0:
		return spawned_cards

	if worker_source == null:
		print("DeckSystemRoot blocked: worker_source missing")
		return spawned_cards

	var target_hand: PlayerHandRoot = _get_hand_for_card_owner(source_card)

	if target_hand == null:
		print("DeckSystemRoot blocked: target hand missing")
		return spawned_cards

	var worker_cards: Array[CardData] = worker_source.build_worker_cards_from_source(
		source_card,
		amount
	)

	for worker_data: CardData in worker_cards:
		if worker_data == null:
			continue

		if respect_hand_limit and target_hand.is_full():
			break

		var spawned_card: CardRoot = target_hand.spawn_card_from_effect(
			worker_data,
			not respect_hand_limit
		)

		if spawned_card != null:
			spawned_cards.append(spawned_card)

	return spawned_cards


func _setup_hand_contexts() -> void:
	if player_one_hand != null:
		player_one_hand.setup_deck_system_context(self)

	if player_two_hand != null:
		player_two_hand.setup_deck_system_context(self)


func _get_hand_for_card_owner(source_card: CardRoot) -> PlayerHandRoot:
	var owner: SlotRow.SlotOwner = _get_owner_for_card(source_card)

	if owner == SlotRow.SlotOwner.OPPONENT:
		return player_two_hand

	return player_one_hand


func _get_owner_for_card(source_card: CardRoot) -> SlotRow.SlotOwner:
	if source_card == null:
		return SlotRow.SlotOwner.PLAYER

	if source_card.slots_root == null:
		return SlotRow.SlotOwner.PLAYER

	var slot: Slot = source_card.get_current_slot()

	if slot == null:
		return SlotRow.SlotOwner.PLAYER

	return source_card.slots_root.get_owner_of_slot(slot)


func _deal_starting_hands_animated(
	p1_cards: Array[CardData],
	p2_cards: Array[CardData]
) -> void:
	await get_tree().create_timer(starting_hand_start_delay).timeout

	var max_count: int = max(p1_cards.size(), p2_cards.size())

	for i: int in range(max_count):
		if i < p1_cards.size():
			_spawn_starting_card(player_one_hand, p1_cards[i])

		if i < p2_cards.size():
			_spawn_starting_card(player_two_hand, p2_cards[i])

		await get_tree().create_timer(starting_hand_card_delay).timeout

	starting_hands_dealt.emit()


func _deal_starting_hand(hand: PlayerHandRoot, cards: Array[CardData]) -> void:
	if hand == null:
		return

	for card_data: CardData in cards:
		_spawn_starting_card(hand, card_data)


func _spawn_starting_card(hand: PlayerHandRoot, card_data: CardData) -> void:
	if hand == null:
		return

	if card_data == null:
		return

	hand.spawn_card(card_data)


func _draw_to_hand(draw_pile: DrawPileRoot, hand: PlayerHandRoot) -> void:
	if draw_pile == null or hand == null:
		return

	var card_data: CardData = draw_pile.draw_card()

	if card_data != null:
		hand.spawn_card(card_data)


func _spawn_worker_to_hand(hand: PlayerHandRoot) -> void:
	if worker_source == null or hand == null:
		return

	var worker: CardData = worker_source.get_worker_card()

	if worker != null:
		hand.spawn_card(worker)


func _to_card_data_array(source: Array) -> Array[CardData]:
	var result: Array[CardData] = []

	for item in source:
		var card_data: CardData = item as CardData

		if card_data != null:
			result.append(card_data)

	return result
