extends Node
class_name HandDragController

@export var hand: PlayerHandRoot
@export var hand_layout: HandLayout

@export var dragged_z_index: int = 200
@export var drag_threshold: float = 12.0

var held_card: CardRoot = null
var dragged_card: CardRoot = null

var press_mouse_position: Vector2 = Vector2.ZERO
var drag_offset: Vector2 = Vector2.ZERO

var drag_enabled := true


func set_drag_enabled(value: bool) -> void:
	drag_enabled = value

	if not drag_enabled:
		_cancel_drag_state()


func _ready() -> void:
	if hand == null:
		hand = get_parent() as PlayerHandRoot

	if hand != null and hand_layout == null:
		hand_layout = hand.hand_layout

	if hand == null:
		return

	hand.card_added.connect(_on_card_added)
	hand.card_removed.connect(_on_card_removed)

	for card in hand.get_cards():
		_connect_card(card)


func _process(_delta: float) -> void:
	if not drag_enabled:
		return

	if held_card == null:
		return

	if dragged_card == null:
		var mouse_distance := held_card.get_global_mouse_position().distance_to(press_mouse_position)

		if mouse_distance >= drag_threshold:
			_start_drag(held_card)

	if dragged_card == null:
		return

	dragged_card.global_position = dragged_card.get_global_mouse_position() + drag_offset
	dragged_card.z_index = dragged_z_index

	if hand_layout == null:
		return

	var new_index := hand_layout.get_insert_index_from_global_x(
		dragged_card.global_position.x,
		hand.get_cards()
	)

	hand.move_card_to_index(dragged_card, new_index)


func _on_card_added(card: CardRoot) -> void:
	_connect_card(card)


func _on_card_removed(card: CardRoot) -> void:
	if held_card == card:
		held_card = null

	if dragged_card == card:
		dragged_card = null


func _connect_card(card: CardRoot) -> void:
	if card == null:
		return

	if not card.pressed.is_connected(_on_card_pressed):
		card.pressed.connect(_on_card_pressed)

	if not card.released.is_connected(_on_card_released):
		card.released.connect(_on_card_released)


func _on_card_pressed(card: CardRoot) -> void:
	if not drag_enabled:
		return

	if hand == null:
		return

	if card == null:
		return

	if not hand.is_card_in_hand(card):
		return

	held_card = card
	press_mouse_position = card.get_global_mouse_position()
	drag_offset = card.global_position - press_mouse_position


func _on_card_released(card: CardRoot) -> void:
	if card == null:
		return

	if held_card != card and dragged_card != card:
		return

	if dragged_card == card:
		_finish_drag(card)

	held_card = null
	dragged_card = null


func _start_drag(card: CardRoot) -> void:
	if hand == null:
		return

	if hand_layout == null:
		return

	if card == null:
		return

	if dragged_card == card:
		return

	dragged_card = card
	hand_layout.set_ignored_card(card)
	hand.arrange_cards()

	var saved_global_transform := card.global_transform

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	hand.drag_layer.add_child(card)
	card.global_transform = saved_global_transform
	card.z_index = dragged_z_index


func _finish_drag(card: CardRoot) -> void:
	if hand == null:
		return

	if hand_layout == null:
		return

	var saved_global_transform := card.global_transform

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	hand.hand_cards_layer.add_child(card)
	card.global_transform = saved_global_transform

	hand_layout.clear_ignored_card()
	hand.arrange_cards()


func _cancel_drag_state() -> void:
	if dragged_card != null:
		_finish_drag(dragged_card)

	held_card = null
	dragged_card = null
