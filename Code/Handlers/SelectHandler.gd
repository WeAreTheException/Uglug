extends Node2D
class_name SelectHandler

static var selected_card: Card = null

@export var slots_root: Node

var slots: Array[NewSlots] = []
var phase_manager: PhaseManager = null

var pending_play_card: Card = null
var selected_sacrifices: Array[Card] = []
var paid_sacrifice_worth: int = 0
var payment_completed: bool = false

func _ready() -> void:
	cache_slots()

func cache_slots() -> void:
	slots.clear()

	if slots_root == null:
		print("cache_slots: slots_root is null")
		return

	_collect_player_slots_recursive(slots_root)

	print("cached player slots = ", slots.size())
	for slot in slots:
		print("cached slot: ", slot.name)

func _collect_player_slots_recursive(node: Node) -> void:
	for child in node.get_children():
		var slot := child as NewSlots
		if slot != null and slot.slot_owner == NewSlots.SlotOwner.PLAYER:
			slots.append(slot)

		_collect_player_slots_recursive(child)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_place_into_slot_under_mouse()

func select_card(card: Card) -> void:
	if card == null:
		return

	if phase_manager != null:
		if card.card_owner != Card.Owner.PLAYER:
			print("select_card blocked: not player-owned card")
			return

		if not phase_manager.is_player_place_phase():
			print("select_card blocked: not in PLAYER_PLACE phase")
			return

	if card.current_slot != null:
		try_select_sacrifice(card)
		return

	try_select_hand_card(card)

func try_select_hand_card(card: Card) -> void:
	if card == null:
		return

	if card.current_slot != null:
		print("try_select_hand_card blocked: card already in slot")
		return

	if payment_completed and pending_play_card != null and pending_play_card != card:
		print("try_select_hand_card blocked: payment already completed for ", pending_play_card.card_name)
		return

	if card.current_cost > 0 and not can_afford_card_selection(card):
		print("select_card blocked: not enough sacrifice value for ", card.card_name)
		return

	if pending_play_card == card:
		cancel_pending_play()
		return

	cancel_pending_play()

	pending_play_card = card
	SelectHandler.selected_card = card
	card.set_selected(true)

	refresh_sacrifice_hints()

	print("pending_play_card = ", pending_play_card.card_name)

func try_select_sacrifice(card: Card) -> void:
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

	refresh_sacrifice_hints()

	if total >= pending_play_card.current_cost:
		resolve_sacrifice_payment()

func resolve_sacrifice_payment() -> void:
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

		sacrifice.kill()

	selected_sacrifices.clear()

	if pending_play_card != null:
		pending_play_card.set_selected(true)

	print("payment complete for ", pending_play_card.card_name, " / paid worth = ", paid_sacrifice_worth)

func try_place_into_slot_under_mouse() -> void:
	if pending_play_card == null:
		return

	var space_state := get_viewport().world_2d.direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_viewport().get_mouse_position()
	params.collide_with_areas = true

	var results := space_state.intersect_point(params)

	for hit in results:
		var collider = hit.collider
		if collider is NewSlots:
			var slot: NewSlots = collider

			if phase_manager != null:
				if not phase_manager.is_player_place_phase():
					print("place blocked: not in PLAYER_PLACE phase")
					return

				if slot.slot_owner != NewSlots.SlotOwner.PLAYER:
					print("place blocked: not a player slot")
					return

			if not slot.is_empty():
				print("place blocked: slot is occupied")
				return

			if pending_play_card.current_cost > 0 and paid_sacrifice_worth < pending_play_card.current_cost:
				print("place blocked: payment not completed")
				return

			resolve_pending_play(slot)
			return

func resolve_pending_play(slot: NewSlots) -> void:
	if pending_play_card == null:
		return

	if slot == null:
		return

	if not slot.is_empty():
		print("resolve blocked: slot is occupied")
		return

	var card_to_play := pending_play_card

	clear_sacrifice_hints()
	clear_current_selection_visuals()

	card_to_play.place_into_slot(slot)

	pending_play_card = null
	selected_sacrifices.clear()
	paid_sacrifice_worth = 0
	payment_completed = false
	SelectHandler.selected_card = null

func cancel_pending_play() -> void:
	clear_sacrifice_hints()
	clear_current_selection_visuals()

	pending_play_card = null
	selected_sacrifices.clear()
	paid_sacrifice_worth = 0
	payment_completed = false
	SelectHandler.selected_card = null

	print("pending play cancelled")

func clear_current_selection_visuals() -> void:
	if pending_play_card != null:
		pending_play_card.set_selected(false)

	for sacrifice in selected_sacrifices:
		if sacrifice != null:
			sacrifice.set_selected(false)

func unselect_current_card() -> void:
	cancel_pending_play()

func can_afford_card_selection(card: Card) -> bool:
	if card == null:
		return false

	if card.current_cost <= 0:
		return true

	var total_worth := get_total_player_board_worth()
	print("checking card: ", card.card_name, " cost=", card.current_cost, " total_worth=", total_worth)

	return total_worth >= card.current_cost

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

func refresh_sacrifice_hints() -> void:
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
