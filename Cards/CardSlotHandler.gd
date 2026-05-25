extends Node
class_name CardSlotHandler

var card: Card = null
var move_tween: Tween = null


func _ready() -> void:
	card = get_parent() as Card


func place_into_slot(slot: NewSlots) -> void:
	if card == null:
		return

	if slot == null:
		return

	if not slot.assign_card(card):
		return

	if card.current_slot != null and card.current_slot != slot:
		card.current_slot.clear_card()

	card.current_slot = slot
	apply_slot_owner(slot)

	if card.player_hand != null:
		if card.player_hand.has_method("remove_card_from_hand"):
			card.player_hand.remove_card_from_hand(card)

	animate_to_position(slot.global_position)


func return_to_hand() -> void:
	if card == null:
		return

	if card.current_slot != null:
		card.current_slot.clear_card()
		card.current_slot = null

	if card.player_hand != null:
		if card.player_hand.has_method("add_card_to_hand"):
			card.player_hand.add_card_to_hand(card)

	card.set_selected(false)


func apply_slot_owner(slot: NewSlots) -> void:
	if card == null:
		return

	if slot == null:
		return

	if slot.slot_owner == NewSlots.SlotOwner.PLAYER:
		card.card_owner = Card.Owner.PLAYER
	else:
		card.card_owner = Card.Owner.OPPONENT


func animate_to_position(target_pos: Vector2) -> void:
	if card == null:
		return

	if move_tween != null:
		move_tween.kill()

	move_tween = card.create_tween()
	move_tween.tween_property(card, "global_position", target_pos, 0.18)
