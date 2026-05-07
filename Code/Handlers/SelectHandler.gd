extends Node
class_name SelectHandler

static var selected_card: Card = null

@export var slots_root: Node
@export var sacrifice_handler: SacrificeHandler
@export var phase_manager: PhaseManager
@export var animation_handler: SelectAnimation

@export var card_database: CardDatabase
@export var card_scene: PackedScene

var slots: Array[NewSlots] = []
var pending_play_card: Card = null

func _ready() -> void:
	cache_slots()

	if sacrifice_handler != null:
		sacrifice_handler.phase_manager = phase_manager

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
	if not can_use_place_logic():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_place_into_slot_under_mouse()

func can_use_place_logic() -> bool:
	if phase_manager == null:
		return true

	return phase_manager.is_place_phase()

func select_card(card: Card) -> void:
	if not can_use_place_logic():
		print("select_card blocked: not place phase")
		return

	if card == null:
		return

	if card.card_owner != Card.Owner.PLAYER:
		print("select_card blocked: not player-owned card")
		return

	if card.current_slot != null:
		print("select_card blocked: card is already on board")
		return

	if pending_play_card != null and pending_play_card != card:
		if sacrifice_handler != null:
			if not sacrifice_handler.payment_completed and pending_play_card.current_cost > 0:
				sacrifice_handler.try_select_sacrifice(card, pending_play_card)
				return

	try_select_hand_card(card)

func try_select_hand_card(card: Card) -> void:
	if not can_use_place_logic():
		print("try_select_hand_card blocked: not place phase")
		return

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
			print("select_card blocked: not enough hand sacrifice value for ", card.card_name)
			return

	if pending_play_card == card:
		cancel_pending_play()
		return

	cancel_pending_play()

	pending_play_card = card
	SelectHandler.selected_card = card

	if animation_handler != null:
		animation_handler.show_card_selected(card)
	else:
		card.set_selected(true)

	if sacrifice_handler != null:
		sacrifice_handler.refresh_sacrifice_hints(pending_play_card)

	print("pending_play_card = ", pending_play_card.card_name)

func try_place_into_slot_under_mouse() -> void:
	if not can_use_place_logic():
		print("place blocked: not place phase")
		return

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
	if not can_use_place_logic():
		print("resolve blocked: not place phase")
		return

	if pending_play_card == null:
		return

	if slot == null:
		return

	if not slot.is_empty():
		print("resolve blocked: slot is occupied")
		return

	var card_to_play := pending_play_card
	var placed_card_id := card_to_play.multiplayer_card_id
	var placed_owner_peer_id := card_to_play.owning_peer_id
	var placed_card_name := card_to_play.card_name
	var placed_lane_id := slot.lane_id

	if sacrifice_handler != null:
		sacrifice_handler.clear_sacrifice_hints()

	clear_current_selection_visuals()

	card_to_play.place_into_slot(slot)

	if multiplayer.multiplayer_peer != null:
		rpc("replicate_place_card", placed_card_id, placed_owner_peer_id, placed_card_name, placed_lane_id)

	pending_play_card = null

	if sacrifice_handler != null:
		sacrifice_handler.reset_state()

	SelectHandler.selected_card = null

@rpc("any_peer", "call_remote", "reliable")
func replicate_place_card(card_id: int, owner_peer_id: int, card_name: String, lane_id: int) -> void:
	var target_slot := find_opposing_slot_by_lane_id(slots_root, lane_id)
	if target_slot == null:
		print("replicate_place_card failed: opposing slot not found for lane ", lane_id)
		return

	if not target_slot.is_empty():
		print("replicate_place_card blocked: mirrored slot occupied")
		return

	var card := find_card_by_multiplayer_data(card_id, owner_peer_id)

	if card == null:
		print("replicate_place_card: card not found in hand, spawning fallback card")
		card = spawn_remote_card(card_id, owner_peer_id, card_name)

	if card == null:
		print("replicate_place_card failed: could not find or spawn card")
		return

	card.place_into_slot(target_slot)

func spawn_remote_card(card_id: int, owner_peer_id: int, card_name: String) -> Card:
	if card_scene == null:
		print("spawn_remote_card failed: card_scene is null")
		return null

	if card_database == null:
		print("spawn_remote_card failed: card_database is null")
		return null

	var data := get_card_data_by_name(card_name)
	if data == null:
		print("spawn_remote_card failed: card data not found for ", card_name)
		return null

	var new_card := card_scene.instantiate() as Card
	if new_card == null:
		print("spawn_remote_card failed: instantiated scene is not Card")
		return null

	new_card.multiplayer_card_id = card_id
	new_card.owning_peer_id = owner_peer_id
	new_card.card_owner = Card.Owner.OPPONENT
	new_card.select_handler = null
	new_card.player_hand = null

	get_tree().current_scene.add_child(new_card)

	new_card.setup_card(data)

	return new_card

func get_card_data_by_name(card_name: String) -> CardData:
	if card_database == null:
		return null

	for data in card_database.cards:
		if data == null:
			continue

		if data.name == card_name:
			return data

	return null

func find_card_by_multiplayer_data(card_id: int, owner_peer_id: int) -> Card:
	var scene := get_tree().current_scene
	if scene == null:
		return null

	return find_card_by_multiplayer_data_recursive(scene, card_id, owner_peer_id)

func find_card_by_multiplayer_data_recursive(node: Node, card_id: int, owner_peer_id: int) -> Card:
	var card := node as Card
	if card != null:
		if card.multiplayer_card_id == card_id and card.owning_peer_id == owner_peer_id:
			return card

	for child in node.get_children():
		var found := find_card_by_multiplayer_data_recursive(child, card_id, owner_peer_id)
		if found != null:
			return found

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
	if animation_handler != null:
		animation_handler.clear_pending_visual(pending_play_card)
		animation_handler.clear_sacrifice_visuals(sacrifice_handler)
		return

	if pending_play_card != null:
		pending_play_card.set_selected(false)

	if sacrifice_handler != null:
		sacrifice_handler.clear_selected_sacrifice_visuals()

func unselect_current_card() -> void:
	cancel_pending_play()
