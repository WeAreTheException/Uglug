extends Mutation
class_name Christmas

@export var cards_to_draw: int = 1
@export var respect_hand_limit: bool = false


func on_placed(
	card: CardRoot,
	_slot: Slot,
	_owner: SlotRow.SlotOwner
) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if card.deck_system_root == null:
		print("Christmas blocked: card.deck_system_root missing")
		return

	card.deck_system_root.draw_random_cards_from_effect_for_card_owner(
		card,
		cards_to_draw,
		respect_hand_limit
	)
