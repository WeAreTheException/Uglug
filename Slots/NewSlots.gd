extends Area2D
class_name NewSlots

enum SlotOwner {
	PLAYER,
	OPPONENT
}

@export var slot_owner: SlotOwner = SlotOwner.PLAYER
@export var select_handler: SelectHandler

var current_card: Node2D = null

func is_empty() -> bool:
	return current_card == null

func assign_card(card: Node2D) -> bool:
	if current_card != null and current_card != card:
		print("assign_card failed: slot occupied")
		return false

	current_card = card
	print("assign_card success: ", card.name, " -> ", name)
	return true

func clear_card() -> void:
	current_card = null

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("slot clicked: ", name)

		if select_handler != null:
			select_handler.try_place_selected_in_slot(self)
		else:
			print("slot click failed: drag_handler is null")
