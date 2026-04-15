extends Node2D
class_name SelectHandler

static var selected_card: Card = null

@export var slots_root: Node

var slots: Array[NewSlots] = []
var phase_manager: PhaseManager = null

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
		if slot != null:
			if slot.slot_owner == NewSlots.SlotOwner.PLAYER:
				slots.append(slot)

		_collect_player_slots_recursive(child)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_place_into_slot_under_mouse()

func select_card(card: Card) -> void:
	if card == null:
		return

	if card.current_slot != null:
		print("select_card blocked: card already in slot")
		return

	if phase_manager != null:
		if card.card_owner != Card.Owner.PLAYER:
			print("select_card blocked: not player-owned card")
			return

		if not phase_manager.is_player_place_phase():
			print("select_card blocked: not in PLAYER_PLACE phase")
			return

	if not can_afford_card_selection(card):
		print("select_card blocked: not enough sacrifice value for ", card.card_name)
		return

	if SelectHandler.selected_card != null and SelectHandler.selected_card != card:
		SelectHandler.selected_card.set_selected(false)

	if SelectHandler.selected_card == card:
		unselect_current_card()
		return

	SelectHandler.selected_card = card
	SelectHandler.selected_card.set_selected(true)

	print("selected_card = ", SelectHandler.selected_card.card_name)

func try_place_into_slot_under_mouse() -> void:
	if SelectHandler.selected_card == null:
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

			SelectHandler.selected_card.place_into_slot(slot)
			SelectHandler.selected_card.set_selected(false)
			SelectHandler.selected_card = null
			return

func unselect_current_card() -> void:
	if SelectHandler.selected_card == null:
		return

	SelectHandler.selected_card.set_selected(false)
	SelectHandler.selected_card = null

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

	print("---- checking board worth ----")
	print("slots size = ", slots.size())

	for slot in slots:
		if slot == null:
			print("slot is null")
			continue

		print("slot name = ", slot.name, " owner = ", slot.slot_owner)

		if slot.current_card == null:
			print("skipped: no current_card")
			continue

		var board_card := slot.current_card as Card
		if board_card == null:
			print("skipped: current_card is not Card")
			continue

		print("found board card: ", board_card.card_name, " worth = ", board_card.current_worth)
		total += board_card.current_worth

	print("total board worth = ", total)
	print("-----------------------------")

	return total
