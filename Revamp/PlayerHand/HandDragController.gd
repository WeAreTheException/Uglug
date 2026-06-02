extends Node
class_name HandDragController

@export var hand: PlayerHandRoot

@export var dragged_z_index: int = 200

var dragged_card: CardRoot = null
var drag_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	if hand == null:
		hand = get_parent() as PlayerHandRoot

	if hand == null:
		return

	hand.card_added.connect(_on_card_added)
	hand.card_removed.connect(_on_card_removed)

	for card in hand.get_cards():
		_connect_card(card)


func _process(_delta: float) -> void:
	if dragged_card == null:
		return

	dragged_card.global_position = dragged_card.get_global_mouse_position() + drag_offset
	dragged_card.z_index = dragged_z_index

	var new_index := hand.get_insert_index_from_global_x(
		dragged_card.global_position.x
	)

	hand.move_card_to_index(
		dragged_card,
		new_index
	)


func _on_card_added(card: CardRoot) -> void:
	_connect_card(card)


func _on_card_removed(card: CardRoot) -> void:
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
	if hand == null:
		return

	if card == null:
		return

	if not hand.is_card_in_hand(card):
		return

	dragged_card = card

	drag_offset = (
		card.global_position
		- card.get_global_mouse_position()
	)

	hand.set_layout_ignored_card(card)

	var saved_global_transform := card.global_transform

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	hand.drag_layer.add_child(card)

	card.global_transform = saved_global_transform
	card.z_index = dragged_z_index


func _on_card_released(card: CardRoot) -> void:
	if card == null:
		return

	if dragged_card != card:
		return

	var saved_global_transform := card.global_transform

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	hand.hand_cards_layer.add_child(card)

	card.global_transform = saved_global_transform

	dragged_card = null

	hand.clear_layout_ignored_card()
