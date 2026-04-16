extends Node2D
class_name SelectHandler

static var selected_card: Card = null

@export var slots_root: Node
@export var card_manager: Node
@export var sacrifice_handler: SacrificeHandler

var slots: Array[NewSlots] = []
var phase_manager: PhaseManager = null

var pending_play_card: Card = null

func _ready() -> void:
	cache_slots()

	if sacrifice_handler != null:
		sacrifice_handler.slots = slots

func cache_slots() -> void:
	slots.clear()

	if slots_root == null:
		print("cache_slots: slots_root is null")
		return

	_collect_player_slots_recursive(slots_root)

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
		if sacrifice_handler != null:
			sacrifice_handler.try_select_sacrifice(card, pending_play_card)
		return

	try_select_hand_card(card)

func try_select_hand_card(card: Card) -> void:
	if card == null:
		return

	if card.current_slot != null:
		print("try_select_hand_card blocked: card already in slot")
		return

	if sacrifice_handler != null:
		if sacrifice_handler.payment_completed and pending_play_card != null:
			if pending_play_card == card:
				print("try_select_hand_card blocked: cannot unselect after payment completed")
				return

			print("try_select_hand_card blocked: payment already completed for ", pending_play_card.card_name)
			return

		if card.current_cost > 0 and not sacrifice_handler.can_afford_card(card):
			print("select_card blocked: not enough sacrifice value for ", card.card_name)
			return

	if pending_play_card == card:
		cancel_pending_play()
		return

	cancel_pending_play()

	pending_play_card = card
	SelectHandler.selected_card = card
	card.set_selected(true)

	if sacrifice_handler != null:
		sacrifice_handler.refresh_sacrifice_hints(pending_play_card)

	print("pending_play_card = ", pending_play_card.card_name)

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

			if pending_play_card.current_cost > 0:
				if sacrifice_handler == null:
					print("place blocked: sacrifice_handler is null")
					return

				if not sacrifice_handler.payment_completed:
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
	var placed_card_id := card_to_play.multiplayer_card_id
	var placed_lane_id := slot.lane_id

	if sacrifice_handler != null:
		sacrifice_handler.clear_sacrifice_hints()

	clear_current_selection_visuals()

	card_to_play.place_into_slot(slot)

	if multiplayer.multiplayer_peer != null:
		rpc("replicate_place_card", placed_card_id, placed_lane_id)

	pending_play_card = null

	if sacrifice_handler != null:
		sacrifice_handler.reset_state()

	SelectHandler.selected_card = null

@rpc("any_peer", "call_remote", "reliable")
func replicate_place_card(card_id: int, lane_id: int) -> void:
	var card := find_card_by_multiplayer_id(card_id)
	if card == null:
		print("replicate_place_card failed: card not found for id ", card_id)
		return

	var target_slot := find_opposing_slot_by_lane_id(slots_root, lane_id)
	if target_slot == null:
		print("replicate_place_card failed: opposing slot not found for lane ", lane_id)
		return

	if not target_slot.is_empty():
		print("replicate_place_card blocked: mirrored slot occupied")
		return

	card.place_into_slot(target_slot)

func find_card_by_multiplayer_id(card_id: int) -> Card:
	if card_manager == null:
		return null

	for child in card_manager.get_children():
		var card := child as Card
		if card == null:
			continue

		if card.multiplayer_card_id == card_id:
			return card

	return null

func find_opposing_slot_by_lane_id(node: Node, lane_id: int) -> NewSlots:
	if node == null:
		return null

	for child in node.get_children():
		var slot := child as NewSlots
		if slot != null:
			if slot.lane_id == lane_id and slot.slot_owner == NewSlots.SlotOwner.OPPONENT:
				return slot

		var found := find_opposing_slot_by_lane_id(child, lane_id)
		if found != null:
			return found

	return null

func cancel_pending_play() -> void:
	if sacrifice_handler != null and sacrifice_handler.payment_completed:
		print("cancel_pending_play blocked: payment already completed")
		return

	if sacrifice_handler != null:
		sacrifice_handler.clear_sacrifice_hints()

	clear_current_selection_visuals()

	pending_play_card = null

	if sacrifice_handler != null:
		sacrifice_handler.reset_state()

	SelectHandler.selected_card = null

	print("pending play cancelled")

func clear_current_selection_visuals() -> void:
	if pending_play_card != null:
		pending_play_card.set_selected(false)

	if sacrifice_handler != null:
		sacrifice_handler.clear_selected_sacrifice_visuals()

func unselect_current_card() -> void:
	cancel_pending_play()
