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
@export var config: PlacementConfigHelper
@export var placement_state: PlacementState
@export var input_router: PlacementInputRouter
@export var placement_preview: PlacementPreview
@export var placement_executor: PlacementExecutor
@export var event_emitter: PlacementEventEmitter
@export var placement_cancel: PlacementCancel

@export var enable_right_click_cancel: bool = true

var slot_resolver := PlacementSlotResolverHelper.new()
var slot_validator := PlacementSlotValidatorHelper.new()
var setup_helper := PlacementControllerSetupHelper.new()
var start_flow := PlacementStartFlowHelper.new()
var confirm_flow := PlacementConfirmFlowHelper.new()


func _ready() -> void:
	setup_helper.setup_children(self)
	setup_helper.connect_external_signals(self)


func _input(event: InputEvent) -> void:
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
