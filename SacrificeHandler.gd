extends Node
class_name SacrificeHandler

@export var player_hand: Node
@export var phase_manager: PhaseManager

var sacrifice_animation: SacrificeAnimation = null

var selected_sacrifices: Array[Card] = []
var paid_sacrifice_worth: int = 0
var payment_completed: bool = false

func _ready() -> void:
	sacrifice_animation = find_child("SacrificeAnimation", false, false) as SacrificeAnimation

	if sacrifice_animation == null:
		print("SacrificeHandler could not find child SacrificeAnimation")

func reset_state() -> void:
	clear_sacrifice_hints()
	clear_selected_sacrifice_visuals()
	selected_sacrifices.clear()
	paid_sacrifice_worth = 0
	payment_completed = false

func can_use_sacrifice_logic() -> bool:
	if phase_manager == null:
		return true

	return phase_manager.is_place_phase()

func can_afford_card(card: Card) -> bool:
	if not can_use_sacrifice_logic():
		return false

	if card == null:
		return false

	if card.current_cost <= 0:
		return true

	return get_total_player_hand_worth(card) >= card.current_cost

func try_select_sacrifice(card: Card, pending_play_card: Card) -> void:
	if not can_use_sacrifice_logic():
		print("sacrifice blocked: not place phase")
		return

	if card == null:
		return

	if pending_play_card == null:
		print("sacrifice blocked: no pending play card")
		return

	if payment_completed:
		print("sacrifice blocked: payment already completed")
		return

	if pending_play_card.current_cost <= 0:
		print("sacrifice blocked: pending play card is free")
		return

	if card == pending_play_card:
		print("sacrifice blocked: cannot sacrifice the card being played")
		return

	if card.current_slot != null:
		print("sacrifice blocked: card is on board")
		return

	if card.card_owner != Card.Owner.PLAYER:
		print("sacrifice blocked: not player card")
		return

	if selected_sacrifices.has(card):
		print("sacrifice blocked: card already chosen")
		return

	selected_sacrifices.append(card)

	if sacrifice_animation != null:
		sacrifice_animation.show_sacrifice_selected(card)
	else:
		card.set_selected(true)

	var total := get_selected_sacrifice_worth()
	print("added hand sacrifice: ", card.card_name, " / total worth = ", total)

	refresh_sacrifice_hints(pending_play_card)

	if total >= pending_play_card.current_cost:
		resolve_sacrifice_payment(pending_play_card)

func resolve_sacrifice_payment(pending_play_card: Card) -> void:
	if not can_use_sacrifice_logic():
		print("resolve sacrifice blocked: not place phase")
		return

	if pending_play_card == null:
		return

	var total := get_selected_sacrifice_worth()
	if total < pending_play_card.current_cost:
		return

	var sacrifices_to_remove := selected_sacrifices.duplicate()
	paid_sacrifice_worth = total
	payment_completed = true

	clear_sacrifice_hints()

	var sacrificed_data: Array = []

	for sacrifice in sacrifices_to_remove:
		if sacrifice == null:
			continue

		sacrificed_data.append({
			"card_id": sacrifice.multiplayer_card_id,
			"owner_peer_id": sacrifice.owning_peer_id
		})

		remove_card_from_player_hand(sacrifice)
		sacrifice.kill()

	selected_sacrifices.clear()

	print("payment complete for ", pending_play_card.card_name, " / paid worth = ", paid_sacrifice_worth)

	if multiplayer.multiplayer_peer != null:
		rpc("replicate_sacrifice", sacrificed_data)

@rpc("any_peer", "call_remote", "reliable")
func replicate_sacrifice(sacrificed_data: Array) -> void:
	for data in sacrificed_data:
		var card_id: int = data["card_id"]
		var owner_peer_id: int = data["owner_peer_id"]

		var card := find_card_by_multiplayer_data(card_id, owner_peer_id)

		if card == null:
			print("replicate_sacrifice failed: card not found for id ", card_id)
			continue

		card.kill()

func find_card_by_multiplayer_data(card_id: int, owner_peer_id: int) -> Card:
	var scene := get_tree().current_scene

	if scene == null:
		return null

	return find_card_by_multiplayer_data_recursive(scene, card_id, owner_peer_id)

func find_card_by_multiplayer_data_recursive(
	node: Node,
	card_id: int,
	owner_peer_id: int
) -> Card:
	var card := node as Card

	if card != null:
		if (
			card.multiplayer_card_id == card_id
			and card.owning_peer_id == owner_peer_id
		):
			return card

	for child in node.get_children():
		var found := find_card_by_multiplayer_data_recursive(
			child,
			card_id,
			owner_peer_id
		)

		if found != null:
			return found

	return null

func get_total_player_hand_worth(pending_play_card: Card = null) -> int:
	var total := 0

	for card in get_player_hand_cards():
		if card == null:
			continue

		if card == pending_play_card:
			continue

		if card.current_slot != null:
			continue

		total += card.current_worth

	return total

func get_selected_sacrifice_worth() -> int:
	var total := 0

	for card in selected_sacrifices:
		if card == null:
			continue

		total += card.current_worth

	return total

func refresh_sacrifice_hints(pending_play_card: Card) -> void:
	clear_sacrifice_hints()

	if not can_use_sacrifice_logic():
		return

	if pending_play_card == null:
		return

	if payment_completed:
		return

	if pending_play_card.current_cost <= 0:
		return

	for card in get_player_hand_cards():
		if card == null:
			continue

		if card == pending_play_card:
			continue

		if card.current_slot != null:
			continue

		if card.card_owner != Card.Owner.PLAYER:
			continue

		if selected_sacrifices.has(card):
			continue

		if sacrifice_animation != null:
			sacrifice_animation.show_sacrifice_hint(card)
		else:
			card.start_sacrifice_hint()

func clear_sacrifice_hints() -> void:
	for card in get_player_hand_cards():
		if card == null:
			continue

		if sacrifice_animation != null:
			sacrifice_animation.hide_sacrifice_hint(card)
		else:
			card.stop_sacrifice_hint()

func clear_selected_sacrifice_visuals() -> void:
	for card in selected_sacrifices:
		if card == null:
			continue

		if sacrifice_animation != null:
			sacrifice_animation.show_sacrifice_unselected(card)
		else:
			card.set_selected(false)

func get_player_hand_cards() -> Array[Card]:
	var cards: Array[Card] = []

	if player_hand == null:
		return cards

	for child in player_hand.get_children():
		var card := child as Card
		if card != null and not cards.has(card):
			cards.append(card)

	var hand_array = player_hand.get("player_hand")

	if hand_array is Array:
		for item in hand_array:
			var card := item as Card

			if card != null and not cards.has(card):
				cards.append(card)

	return cards

func remove_card_from_player_hand(card: Card) -> void:
	if card == null:
		return

	if player_hand == null:
		return

	if player_hand.has_method("remove_card_from_hand"):
		player_hand.remove_card_from_hand(card)
		return

	if player_hand.has_method("remove_card"):
		player_hand.remove_card(card)
		return

	var hand_array = player_hand.get("player_hand")

	if hand_array is Array:
		hand_array.erase(card)
