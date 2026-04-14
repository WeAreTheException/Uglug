extends Area2D
class_name NewSlots

enum SlotOwner {
	PLAYER,
	OPPONENT
}

@export var slot_owner: SlotOwner = SlotOwner.PLAYER
@export var opposing_slot: NewSlots

var current_card: Node2D = null

func is_empty() -> bool:
	return current_card == null

func can_accept_card(card: Node2D) -> bool:
	if card == null:
		return false

	var c := card as Card
	if c == null:
		return false

	if c.card_owner != slot_owner:
		print("wrong side")
		return false

	return current_card == null or current_card == card

func assign_card(card: Node2D) -> bool:
	if not can_accept_card(card):
		print("slot full")
		return false

	current_card = card
	return true

func clear_card() -> void:
	current_card = null
