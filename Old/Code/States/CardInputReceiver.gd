extends Node
class_name CardInputReceiver

@export var card_state_machine: CardStateMachine
@export var card_input_listener: CardInputListener
@export var card_root: Card

var select_handler: SelectHandler = null
var is_hovered: bool = false


func _ready() -> void:
	if card_root == null:
		card_root = get_parent() as Card

	if card_input_listener == null and card_root != null:
		card_input_listener = card_root.get_node_or_null("CardInputListener") as CardInputListener

	if select_handler == null and card_root != null:
		select_handler = card_root.select_handler

	if card_input_listener == null:
		print("CardInputReceiver blocked: card_input_listener is null")
		return

	card_input_listener.hovered.connect(_on_card_hovered)
	card_input_listener.hovered_off.connect(_on_card_hovered_off)
	card_input_listener.pressed.connect(_on_card_pressed)
	card_input_listener.released.connect(_on_card_released)

	if card_input_listener.has_signal("slot_entered"):
		card_input_listener.slot_entered.connect(_on_slot_entered)

	if card_input_listener.has_signal("slot_exited"):
		card_input_listener.slot_exited.connect(_on_slot_exited)


func _on_card_hovered(_card) -> void:
	is_hovered = true

	if card_root != null:
		card_root.is_hovered = true


func _on_card_hovered_off(_card) -> void:
	is_hovered = false

	if card_root != null:
		card_root.is_hovered = false


func _on_card_pressed(_card) -> void:
	if card_root == null:
		return

	if select_handler == null:
		select_handler = card_root.select_handler

	if select_handler == null:
		print("card pressed blocked: select_handler is null on ", card_root.card_name)
		return

	if card_root.current_slot != null:
		return

	select_handler.select_card(card_root)


func _on_card_released(_card) -> void:
	pass


func _on_slot_entered(slot: NewSlots) -> void:
	if card_root == null:
		return

	card_root.overlapping_slot = slot


func _on_slot_exited(slot: NewSlots) -> void:
	if card_root == null:
		return

	if card_root.overlapping_slot == slot:
		card_root.overlapping_slot = null
