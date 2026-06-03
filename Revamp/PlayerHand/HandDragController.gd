extends Node
class_name Hand_DragController

const DRAG_LOCK_META := "hand_drag_locked"

@export var held_z_index: int = 100
@export var dragged_z_index: int = 200
@export var drag_threshold: float = 12.0

var interaction_root: Hand_InteractionRoot = null

var held_card: CardRoot = null
var dragged_card: CardRoot = null

var press_mouse_position: Vector2 = Vector2.ZERO
var drag_offset: Vector2 = Vector2.ZERO
var last_insert_index: int = -1

var drag_enabled: bool = true


func setup(source_interaction_root: Hand_InteractionRoot) -> void:
	interaction_root = source_interaction_root


func set_drag_enabled(value: bool) -> void:
	drag_enabled = value

	if not drag_enabled:
		_cancel_drag_state()


func handle_card_pressed(card: CardRoot) -> void:
	if not drag_enabled:
		return

	if interaction_root == null:
		return

	if card == null:
		return

	if not interaction_root.is_card_in_hand(card):
		return

	_cancel_previous_hold(card)

	held_card = card
	dragged_card = null
	last_insert_index = interaction_root.get_card_index(card)

	press_mouse_position = card.get_global_mouse_position()
	drag_offset = card.global_position - press_mouse_position

	card.z_index = held_z_index
	card.set_meta(DRAG_LOCK_META, true)
	card.set_drag_feedback(true)


func handle_card_released(card: CardRoot) -> void:
	if card == null:
		return

	if held_card != card and dragged_card != card:
		return

	card.set_drag_feedback(false)
	card.set_meta(DRAG_LOCK_META, false)

	if dragged_card == card:
		_finish_drag(card)
	else:
		interaction_root.arrange_cards()

	held_card = null
	dragged_card = null
	last_insert_index = -1

	interaction_root.refresh_hover_focus()


func forget_card(card: CardRoot) -> void:
	if held_card == card:
		held_card = null

	if dragged_card == card:
		dragged_card = null


func _process(_delta: float) -> void:
	if not drag_enabled:
		return

	if held_card == null:
		return

	if dragged_card == null:
		var distance := held_card.get_global_mouse_position().distance_to(
			press_mouse_position
		)

		if distance >= drag_threshold:
			_start_drag(held_card)

	if dragged_card != null:
		_update_dragged_card()


func _start_drag(card: CardRoot) -> void:
	if interaction_root == null:
		return

	if card == null:
		return

	dragged_card = card
	interaction_root.begin_drag(card)
	card.z_index = dragged_z_index


func _update_dragged_card() -> void:
	if interaction_root == null:
		return

	_apply_drag_position()

	var new_index := interaction_root.get_insert_index_from_global_x(
		dragged_card.global_position.x
	)

	if new_index != last_insert_index:
		last_insert_index = new_index
		interaction_root.move_card_to_index(dragged_card, new_index)
		interaction_root.arrange_cards()

	_apply_drag_position()


func _apply_drag_position() -> void:
	dragged_card.global_position = (
		dragged_card.get_global_mouse_position() + drag_offset
	)

	dragged_card.z_index = dragged_z_index


func _finish_drag(card: CardRoot) -> void:
	if interaction_root != null:
		interaction_root.finish_drag(card)


func _cancel_drag_state() -> void:
	if dragged_card != null:
		dragged_card.set_meta(DRAG_LOCK_META, false)
		dragged_card.set_drag_feedback(false)
		_finish_drag(dragged_card)

	if held_card != null:
		held_card.set_meta(DRAG_LOCK_META, false)
		held_card.set_drag_feedback(false)

	held_card = null
	dragged_card = null
	last_insert_index = -1


func _cancel_previous_hold(new_card: CardRoot) -> void:
	if held_card == null:
		return

	if held_card == new_card:
		return

	held_card.set_meta(DRAG_LOCK_META, false)
	held_card.set_drag_feedback(false)

	held_card = null
	dragged_card = null
