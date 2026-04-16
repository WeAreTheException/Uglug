extends Node
class_name SacrificeHandler

var slots: Array[NewSlots] = []

var selected_sacrifices: Array[Card] = []
var paid_sacrifice_worth: int = 0
var payment_completed: bool = false

func reset_state() -> void:
	clear_sacrifice_hints()
	clear_selected_sacrifice_visuals()
	selected_sacrifices.clear()
	paid_sacrifice_worth = 0
	payment_completed = false

func can_afford_card(card: Card) -> bool:
	if card == null:
		return false

	if card.current_cost <= 0:
		return true

	return get_total_player_board_worth() >= card.current_cost

func try_select_sacrifice(card: Card, pending_play_card: Card) -> void:
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

	if card.current_slot == null:
		print("sacrifice blocked: card not in slot")
		return

	if card.current_slot.slot_owner != NewSlots.SlotOwner.PLAYER:
		print("sacrifice blocked: not in player slot")
		return

	if selected_sacrifices.has(card):
		print("sacrifice blocked: card already chosen")
		return

	selected_sacrifices.append(card)
	card.set_selected(true)

	var total := get_selected_sacrifice_worth()
	print("added sacrifice: ", card.card_name, " / total worth = ", total)

	refresh_sacrifice_hints(pending_play_card)

	if total >= pending_play_card.current_cost:
		resolve_sacrifice_payment(pending_play_card)

func resolve_sacrifice_payment(pending_play_card: Card) -> void:
	if pending_play_card == null:
		return

	var total := get_selected_sacrifice_worth()
	if total < pending_play_card.current_cost:
		return

	var sacrifices_to_remove := selected_sacrifices.duplicate()
	paid_sacrifice_worth = total
	payment_completed = true

	clear_sacrifice_hints()

	for sacrifice in sacrifices_to_remove:
		if sacrifice == null:
			continue

		if sacrifice.current_slot != null:
			sacrifice.current_slot.clear_card()

	for sacrifice in sacrifices_to_remove:
		if sacrifice == null:
			continue
		sacrifice.queue_free()

	selected_sacrifices.clear()

	print("payment complete for ", pending_play_card.card_name, " / paid worth = ", paid_sacrifice_worth)

func get_total_player_board_worth() -> int:
	var total := 0

	for slot in slots:
		if slot == null:
			continue

		if slot.current_card == null:
			continue

		var board_card := slot.current_card as Card
		if board_card == null:
			continue

		total += board_card.current_worth

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

	if pending_play_card == null:
		return

	if payment_completed:
		return

	if pending_play_card.current_cost <= 0:
		return

	for slot in slots:
		if slot == null:
			continue

		if slot.current_card == null:
			continue

		var board_card := slot.current_card as Card
		if board_card == null:
			continue

		if selected_sacrifices.has(board_card):
			continue

		board_card.start_sacrifice_hint()

func clear_sacrifice_hints() -> void:
	for slot in slots:
		if slot == null:
			continue

		if slot.current_card == null:
			continue

		var board_card := slot.current_card as Card
		if board_card == null:
			continue

		board_card.stop_sacrifice_hint()

func clear_selected_sacrifice_visuals() -> void:
	for card in selected_sacrifices:
		if card == null:
			continue

		card.set_selected(false)
