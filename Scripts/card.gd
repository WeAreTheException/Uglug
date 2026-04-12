extends Node2D
class_name Card

@export var input_listener: CardInputListener
@export var drag_handler: CardDragHandler

var player_hand: Node2D = null
var current_slot: NewSlots = null
var overlapping_slot: NewSlots = null
var hand_position: Vector2
var is_hovered: bool = false

func _ready() -> void:
	if input_listener == null:
		return

	input_listener.hovered.connect(_on_hovered)
	input_listener.hovered_off.connect(_on_hovered_off)
	input_listener.pressed.connect(_on_pressed)
	input_listener.released.connect(_on_released)
	input_listener.slot_entered.connect(_on_slot_entered)
	input_listener.slot_exited.connect(_on_slot_exited)

func _on_hovered(_listener) -> void:
	is_hovered = true

func _on_hovered_off(_listener) -> void:
	is_hovered = false

func _on_pressed(_listener) -> void:
	if drag_handler == null:
		return

	# free old slot if this card came from one
	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	# remove from hand if this card was in hand
	if player_hand != null:
		player_hand.remove_card_from_hand(self)

	drag_handler.start_drag(self)

func _on_released(_listener) -> void:
	if drag_handler == null:
		return

	drag_handler.stop_drag()

	if overlapping_slot != null:
		place_into_slot(overlapping_slot)
	else:
		return_to_hand()

func _on_slot_entered(slot: NewSlots) -> void:
	overlapping_slot = slot

func _on_slot_exited(slot: NewSlots) -> void:
	if overlapping_slot == slot:
		overlapping_slot = null

func place_into_slot(slot: NewSlots) -> void:
	if slot == null:
		return_to_hand()
		return

	# kick old card out if slot already occupied
	if slot.current_card != null and slot.current_card != self:
		var old_card = slot.current_card
		slot.clear_card()

		old_card.current_slot = null
		if old_card.player_hand != null:
			old_card.player_hand.add_card_to_hand(old_card)

	slot.assign_card(self)
	current_slot = slot
	global_position = slot.global_position

func return_to_hand() -> void:
	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	if player_hand != null:
		player_hand.add_card_to_hand(self)
