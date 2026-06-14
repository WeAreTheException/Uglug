extends Node
class_name BuffSelectionState

signal selection_changed(slot_owner: SlotRow.SlotOwner, card: CardRoot)
signal selections_cleared

@export var debug_card: CardRoot
@export var debug_replacement_card: CardRoot
@export var run_debug_test_on_ready: bool = false

var selected_cards: Dictionary = {}


func _ready() -> void:
	if run_debug_test_on_ready:
		debug_smoke_test()


func clear_selections() -> void:
	selected_cards.clear()
	selections_cleared.emit()


func select_card(
	slot_owner: SlotRow.SlotOwner,
	card: CardRoot
) -> bool:
	if card == null:
		print("BuffSelection blocked: card is null")
		return false

	if not _is_valid_buff_target(card):
		print("BuffSelection blocked: invalid card")
		return false

	selected_cards[slot_owner] = card
	selection_changed.emit(slot_owner, card)

	print("BuffSelection selected card for owner: ", slot_owner)
	return true


func has_selection(slot_owner: SlotRow.SlotOwner) -> bool:
	return selected_cards.has(slot_owner)


func get_selected_card(slot_owner: SlotRow.SlotOwner) -> CardRoot:
	if not selected_cards.has(slot_owner):
		return null

	var card := selected_cards[slot_owner] as CardRoot

	if card == null:
		return null

	if not is_instance_valid(card):
		selected_cards.erase(slot_owner)
		return null

	return card


func is_selected_card(card: CardRoot) -> bool:
	if card == null:
		return false

	for selected_card in selected_cards.values():
		if selected_card == card:
			return true

	return false


func debug_smoke_test() -> void:
	print("--- BUFF SELECTION SMOKE TEST ---")

	print("Select null: ", select_card(SlotRow.SlotOwner.PLAYER, null))

	if debug_card != null:
		print("Select card: ", select_card(SlotRow.SlotOwner.PLAYER, debug_card))
		print(
			"Selection stored: ",
			get_selected_card(SlotRow.SlotOwner.PLAYER) == debug_card
		)

	if debug_replacement_card != null:
		print(
			"Select replacement card: ",
			select_card(SlotRow.SlotOwner.PLAYER, debug_replacement_card)
		)
		print(
			"Previous selection replaced: ",
			get_selected_card(SlotRow.SlotOwner.PLAYER) == debug_replacement_card
		)

	clear_selections()
	print("Clear selection works: ", not has_selection(SlotRow.SlotOwner.PLAYER))

	print("--- END BUFF SELECTION SMOKE TEST ---")


func _is_valid_buff_target(card: CardRoot) -> bool:
	if card.is_on_board():
		return false

	if card.mutations == null:
		return false

	return true
