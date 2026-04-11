extends Node2D
class_name Card

@export var input_listener: CardInputListener
@export var drag_handler: CardDragHandler

var current_slot: CardSlot = null
var overlapping_slot: CardSlot = null
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

	if current_slot != null:
		current_slot.card_in_slot = false
		current_slot = null

	drag_handler.start_drag(self)

func _on_released(_listener) -> void:
	if drag_handler == null:
		return

	drag_handler.stop_drag()

	if overlapping_slot != null and not overlapping_slot.card_in_slot:
		snap_to_slot(overlapping_slot)

func _on_slot_entered(slot: CardSlot) -> void:
	overlapping_slot = slot

func _on_slot_exited(slot: CardSlot) -> void:
	if overlapping_slot == slot:
		overlapping_slot = null

func snap_to_slot(slot: CardSlot) -> void:
	global_position = slot.global_position
	current_slot = slot
	slot.card_in_slot = true
