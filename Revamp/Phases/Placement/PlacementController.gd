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

@export var placement_state: PlacementState
@export var input_router: PlacementInputRouter
@export var slot_resolver: PlacementSlotResolver
@export var placement_preview: PlacementPreview
@export var attack_preview_resolver: PlacementAttackPreviewResolver
@export var placement_executor: PlacementExecutor
@export var event_emitter: PlacementEventEmitter
@export var cleanup: PlacementCleanup

@export var placing_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
@export var player_left_to_right: bool = true
@export var opponent_left_to_right: bool = false
@export var preview_move_time: float = 0.08


func _ready() -> void:
	_setup_children()
	_connect_external_signals()


func start_placement(card: CardRoot, owner: SlotRow.SlotOwner) -> void:
	if card == null:
		_block("No card to place.")
		return

	if placement_state == null:
		_block("Missing PlacementState.")
		return

	cancel_placement(false)

	_set_hand_input_enabled(false)

	placement_state.start(card, owner)

	var default_slot := slot_resolver.get_default_slot(owner)

	if default_slot == null:
		_block("No empty placement slot.")
		cancel_placement(true)
		return

	request_preview_slot(default_slot)
	placement_started.emit(card, default_slot)


func request_preview_slot(slot: Slot) -> void:
	if not is_placing():
		return

	if not is_valid_placement_slot(slot):
		return

	if cleanup != null:
		cleanup.clear_preview_feedback()

	placement_state.set_preview_slot(slot)

	if placement_preview != null:
		placement_preview.show_preview(
			placement_state.active_card,
			slot,
			preview_move_time
		)

	if attack_preview_resolver != null:
		attack_preview_resolver.show_preview(
			placement_state.active_card,
			slot
		)

	placement_preview_changed.emit(placement_state.active_card, slot)


func confirm_placement() -> void:
	if not is_placing():
		return

	if not is_valid_placement_slot(placement_state.preview_slot):
		_block("Invalid placement slot.")
		return

	placement_state.is_confirming = true

	var event := placement_executor.confirm_placement(
		placement_state.active_card,
		placement_state.preview_slot,
		placement_state.active_owner
	)

	if event.is_empty():
		placement_state.is_confirming = false
		_block("Placement failed.")
		return

	var emitted_event := event.duplicate(true)

	if cleanup != null:
		cleanup.clear_preview_feedback()

	if sacrifice_controller != null:
		sacrifice_controller.commit_pending_sacrifice()

	if event_emitter != null:
		event_emitter.emit_card_placed(emitted_event)

	card_placed.emit(emitted_event)
	placement_finished.emit(emitted_event)

	placement_state.reset()
	_set_hand_input_enabled(true)


func cancel_placement(undo_pending_sacrifice: bool = true) -> void:
	if placement_state == null:
		return

	if not placement_state.has_active_card():
		return

	if cleanup != null:
		cleanup.clear_preview_feedback()

	placement_state.reset()
	_set_hand_input_enabled(true)

	if undo_pending_sacrifice and sacrifice_controller != null:
		sacrifice_controller.undo_pending_sacrifice()

	placement_cancelled.emit()


func is_placing() -> bool:
	return placement_state != null and placement_state.is_placing


func is_confirming() -> bool:
	return placement_state != null and placement_state.is_confirming


func is_valid_placement_slot(slot: Slot) -> bool:
	if slot_resolver == null:
		return false

	if placement_state == null:
		return false

	return slot_resolver.is_valid_slot(slot, placement_state.active_owner)


func get_left_to_right(owner: SlotRow.SlotOwner) -> bool:
	if owner == SlotRow.SlotOwner.OPPONENT:
		return opponent_left_to_right

	return player_left_to_right


func get_slots_root() -> SlotsRoot:
	return slots_root


func get_player_hand() -> PlayerHandRoot:
	return player_hand


func _setup_children() -> void:
	for child in [
		placement_state,
		input_router,
		slot_resolver,
		placement_preview,
		attack_preview_resolver,
		placement_executor,
		event_emitter,
		cleanup
	]:
		if child != null and child.has_method("setup"):
			child.setup(self)


func _connect_external_signals() -> void:
	if slots_root != null and input_router != null:
		_connect_signal(slots_root.slot_hovered, input_router.handle_slot_hovered)
		_connect_signal(slots_root.slot_unhovered, input_router.handle_slot_unhovered)
		_connect_signal(slots_root.slot_clicked, input_router.handle_slot_clicked)

	if sacrifice_controller != null:
		_connect_signal(
			sacrifice_controller.pending_sacrifice_started,
			_on_pending_sacrifice_started
		)

		_connect_signal(
			sacrifice_controller.pending_sacrifice_undone,
			_on_pending_sacrifice_undone
		)

	if player_hand != null:
		_connect_signal(player_hand.card_unprimed, _on_card_unprimed)


func _connect_signal(source_signal: Signal, target: Callable) -> void:
	if not source_signal.is_connected(target):
		source_signal.connect(target)


func _on_pending_sacrifice_started(
	primed_card: CardRoot,
	_cards: Array[CardRoot]
) -> void:
	start_placement(primed_card, placing_owner)


func _on_pending_sacrifice_undone(
	_primed_card: CardRoot,
	_cards: Array[CardRoot]
) -> void:
	cancel_placement(false)


func _on_card_unprimed(_card: CardRoot) -> void:
	if is_confirming():
		return

	cancel_placement(true)


func _set_hand_input_enabled(value: bool) -> void:
	if player_hand != null:
		player_hand.set_hand_input_enabled(value)


func _block(reason: String) -> void:
	placement_blocked.emit(reason)
