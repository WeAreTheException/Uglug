extends Node
class_name Hand_DragController
const DRAG_LOCK_META := "hand_drag_locked"
@export var held_z_index: int = 100
@export var dragged_z_index: int = 200
@export var drag_threshold: float = 12.0
var interaction_root: Hand_InteractionRoot = null
var drag_enabled: bool = true
var state := HandDragStateHelper.new()
var mover := HandDragMoverHelper.new()
var reorder := HandDragReorderHelper.new()
func setup(source_interaction_root: Hand_InteractionRoot) -> void:
	interaction_root = source_interaction_root
func set_drag_enabled(value: bool) -> void:
	drag_enabled = value
	if not drag_enabled:
		_cancel_drag_state()
func handle_card_pressed(card: CardRoot) -> void:
	if not _can_hold_card(card):
		return
	_cancel_previous_hold(card)
	state.held_card = card
	state.dragged_card = null
	state.last_insert_index = interaction_root.get_card_index(card)
	state.press_mouse_position = card.get_global_mouse_position()
	state.drag_offset = card.global_position - state.press_mouse_position
	_set_card_drag_state(card, true, held_z_index)
func handle_card_released(card: CardRoot) -> void:
	if card == null:
		return
	if state.held_card != card and state.dragged_card != card:
		return
	_set_card_drag_state(card, false, card.z_index)
	if state.dragged_card == card:
		interaction_root.finish_drag(card)
	else:
		interaction_root.arrange_cards()
	state.reset()
	interaction_root.refresh_hover_focus()
func forget_card(card: CardRoot) -> void:
	if state.held_card == card or state.dragged_card == card:
		state.reset()
func _process(_delta: float) -> void:
	if not drag_enabled or state.held_card == null:
		return
	if state.dragged_card == null:
		_try_start_drag()
	if state.dragged_card != null:
		_update_drag()
func _try_start_drag() -> void:
	var distance := state.held_card.get_global_mouse_position().distance_to(
		state.press_mouse_position
	)
	if distance < drag_threshold:
		return
	state.dragged_card = state.held_card
	interaction_root.begin_drag(state.dragged_card)
	state.dragged_card.z_index = dragged_z_index
func _update_drag() -> void:
	mover.apply_drag_position(state.dragged_card, state.drag_offset, dragged_z_index)
	state.last_insert_index = reorder.update_drag_reorder(
		state.dragged_card,
		state.last_insert_index,
		interaction_root
	)
	mover.apply_drag_position(state.dragged_card, state.drag_offset, dragged_z_index)
func _can_hold_card(card: CardRoot) -> bool:
	return drag_enabled and interaction_root != null and card != null and interaction_root.is_card_in_hand(card)
func _cancel_previous_hold(new_card: CardRoot) -> void:
	if state.held_card == null or state.held_card == new_card:
		return
	_set_card_drag_state(state.held_card, false, state.held_card.z_index)
	state.reset()
func _cancel_drag_state() -> void:
	if state.dragged_card != null:
		_set_card_drag_state(state.dragged_card, false, state.dragged_card.z_index)
		interaction_root.finish_drag(state.dragged_card)
	if state.held_card != null:
		_set_card_drag_state(state.held_card, false, state.held_card.z_index)
	state.reset()
func _set_card_drag_state(card: CardRoot, value: bool, z_value: int) -> void:
	if card == null:
		return
	card.set_meta(DRAG_LOCK_META, value)
	card.set_drag_feedback(value)
	if value:
		card.z_index = z_value
