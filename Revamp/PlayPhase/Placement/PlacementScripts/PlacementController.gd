extends Node
class_name PlacementController

signal placement_started(card: CardRoot, slot: Slot)
signal placement_preview_changed(card: CardRoot, slot: Slot)
signal placement_finished(event: Dictionary)
signal placement_cancelled
signal placement_blocked(reason: String)
signal card_placed(event: Dictionary)

@export var slots_root: SlotsRoot
@export var player_hand: PlayerHandRoot
@export var sacrifice_controller: SacrificeController
@export var match_network_root: MatchNetworkRoot

@export var config: PlacementConfigHelper
@export var placement_state: PlacementState
@export var input_router: PlacementInputRouter
@export var placement_preview: PlacementPreview
@export var placement_executor: PlacementExecutor
@export var event_emitter: PlacementEventEmitter
@export var placement_cancel: PlacementCancel

@export var enable_right_click_cancel: bool = true
@export var enable_payload_debug: bool = false
@export var payload_debug_key: Key = KEY_P

var slot_resolver := PlacementSlotResolverHelper.new()
var slot_validator := PlacementSlotValidatorHelper.new()
var setup_helper := PlacementControllerSetupHelper.new()
var start_flow := PlacementStartFlowHelper.new()
var confirm_flow := PlacementConfirmFlowHelper.new()
var payload_builder := PlacementRequestPayloadBuilder.new()


func _ready() -> void:
	setup_helper.setup_children(self)
	setup_helper.connect_external_signals(self)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if enable_payload_debug and event.keycode == payload_debug_key:
				print("PLACEMENT PAYLOAD DEBUG: ", build_current_placement_payload_debug())

	if not enable_right_click_cancel:
		return

	if not is_placing():
		return

	if is_confirming():
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement(true)


func start_placement(card: CardRoot, owner: SlotRow.SlotOwner) -> void:
	start_flow.start(self, card, owner)


func request_preview_slot(slot: Slot) -> void:
	if not is_placing() or not is_valid_placement_slot(slot):
		return

	placement_state.set_preview_slot(slot)

	if placement_preview != null:
		placement_preview.show_preview(
			placement_state.active_card,
			slot,
			get_preview_move_time()
		)

	placement_preview_changed.emit(placement_state.active_card, slot)


func confirm_placement() -> void:
	confirm_flow.confirm(self)


func apply_confirmed_placement(payload: Dictionary) -> void:
	if payload.is_empty():
		block("Confirmed placement payload empty.")
		return

	if slots_root == null:
		block("Confirmed placement blocked: slots_root missing.")
		return

	if placement_executor == null:
		block("Confirmed placement blocked: placement_executor missing.")
		return

	var card_id: String = payload.get("placed_card_runtime_id", "")
	var slot_owner: SlotRow.SlotOwner = payload.get("target_slot_owner", SlotRow.SlotOwner.PLAYER)
	var slot_index: int = payload.get("target_slot_index", -1)
	var owner: SlotRow.SlotOwner = payload.get("owner", SlotRow.SlotOwner.PLAYER)

	var card := _find_card_for_confirmed_placement(card_id)
	var slot := _get_confirmed_target_slot(owner, slot_owner, slot_index)

	if card == null:
		block("Confirmed placement blocked: card missing.")
		return

	if slot == null:
		block("Confirmed placement blocked: slot missing.")
		return

	if not slot.is_empty():
		block("Confirmed placement blocked: slot occupied.")
		return

	var source_hand := _get_source_hand_for_owner(owner)
	var event := placement_executor.confirm_network_placement(
		card,
		slot,
		owner,
		source_hand
	)

	if event.is_empty():
		block("Confirmed placement failed.")
		return

	_finish_confirmed_placement(event)


func cancel_placement(undo_pending_sacrifice: bool = true) -> void:
	if placement_state == null or not placement_state.has_active_card():
		return

	if placement_cancel != null:
		placement_cancel.cancel_placement(undo_pending_sacrifice)

	placement_cancelled.emit()


func set_active_owner(owner: SlotRow.SlotOwner) -> void:
	if config != null:
		config.placing_owner = owner


func is_placing() -> bool:
	return placement_state != null and placement_state.is_placing


func is_confirming() -> bool:
	return placement_state != null and placement_state.is_confirming


func is_valid_placement_slot(slot: Slot) -> bool:
	if placement_state == null:
		return false

	return slot_validator.is_valid_slot(
		slots_root,
		slot,
		placement_state.active_owner
	)


func build_current_placement_payload() -> Dictionary:
	if placement_state == null:
		return {}

	if slots_root == null:
		return {}

	if sacrifice_controller == null:
		return {}

	return payload_builder.build_payload(
		slots_root,
		placement_state.active_card,
		placement_state.preview_slot,
		placement_state.active_owner,
		sacrifice_controller.get_pending_sacrifice_cards()
	)


func build_current_placement_payload_debug() -> Dictionary:
	return build_current_placement_payload()


func get_left_to_right(owner: SlotRow.SlotOwner) -> bool:
	if config == null:
		return owner == SlotRow.SlotOwner.PLAYER

	if owner == SlotRow.SlotOwner.OPPONENT:
		return config.opponent_left_to_right

	return config.player_left_to_right


func get_preview_move_time() -> float:
	if config == null:
		return 0.08

	return config.preview_move_time


func get_placing_owner() -> SlotRow.SlotOwner:
	if config == null:
		return SlotRow.SlotOwner.PLAYER

	return config.placing_owner


func get_slots_root() -> SlotsRoot:
	return slots_root


func get_player_hand() -> PlayerHandRoot:
	return player_hand


func set_hand_input_enabled(value: bool) -> void:
	if player_hand != null:
		player_hand.set_hand_input_enabled(value)


func undo_pending_sacrifice() -> void:
	if sacrifice_controller != null:
		sacrifice_controller.undo_pending_sacrifice()


func _finish_confirmed_placement(event: Dictionary) -> void:
	var emitted_event := event.duplicate(true)

	if placement_preview != null:
		placement_preview.clear_preview()

	if sacrifice_controller != null:
		sacrifice_controller.commit_pending_sacrifice()

	if event_emitter != null:
		event_emitter.emit_card_placed(emitted_event)

	card_placed.emit(emitted_event)
	placement_finished.emit(emitted_event)

	if placement_state != null:
		placement_state.reset()

	set_hand_input_enabled(true)

	if slots_root != null:
		slots_root.refresh_board_mutations()


func _find_card_for_confirmed_placement(runtime_id: String) -> CardRoot:
	var clean_id := runtime_id.strip_edges()

	if clean_id == "":
		return null

	if match_network_root != null:
		var card := match_network_root.find_card_anywhere(clean_id)

		if card != null:
			return card

	if player_hand != null:
		return player_hand.find_card_by_runtime_id(clean_id)

	return null


func _get_source_hand_for_owner(owner: SlotRow.SlotOwner) -> PlayerHandRoot:
	if match_network_root == null:
		return player_hand

	if match_network_root.deck_system_root == null:
		return player_hand

	return match_network_root.deck_system_root.get_hand_for_owner(owner)


func _on_pending_sacrifice_started(
	primed_card: CardRoot,
	_cards: Array[CardRoot]
) -> void:
	start_placement(primed_card, get_placing_owner())


func _on_pending_sacrifice_undone(
	_primed_card: CardRoot,
	_cards: Array[CardRoot]
) -> void:
	cancel_placement(false)


func _on_card_unprimed(_card: CardRoot) -> void:
	if not is_confirming():
		cancel_placement(true)


func block(reason: String) -> void:
	placement_blocked.emit(reason)
	
func _get_confirmed_target_slot(
	owner: SlotRow.SlotOwner,
	slot_owner: SlotRow.SlotOwner,
	logical_slot_index: int
) -> Slot:
	if slots_root == null:
		return null

	var local_slot_owner := _get_local_visual_slot_owner(slot_owner)
	var local_index := _get_local_visual_slot_index(owner, logical_slot_index)

	return slots_root.get_slot(local_slot_owner, local_index)


func _get_local_visual_slot_index(
	owner: SlotRow.SlotOwner,
	logical_slot_index: int
) -> int:
	if _should_mirror_confirmed_slot(owner):
		return _mirror_slot_index(logical_slot_index)

	return logical_slot_index


func _should_mirror_confirmed_slot(owner: SlotRow.SlotOwner) -> bool:
	if match_network_root == null:
		return false

	return match_network_root.get_local_owner() != owner


func _mirror_slot_index(slot_index: int) -> int:
	var max_slots := 4

	if slots_root != null:
		var slots := slots_root.get_slots_for_owner(SlotRow.SlotOwner.PLAYER)
		if not slots.is_empty():
			max_slots = slots.size()

	return (max_slots + 1) - slot_index

func _get_local_visual_slot_owner(slot_owner: SlotRow.SlotOwner) -> SlotRow.SlotOwner:
	if match_network_root == null:
		return slot_owner

	var local_owner := match_network_root.get_local_owner()

	if local_owner == SlotRow.SlotOwner.PLAYER:
		return slot_owner

	if slot_owner == SlotRow.SlotOwner.PLAYER:
		return SlotRow.SlotOwner.OPPONENT

	return SlotRow.SlotOwner.PLAYER
