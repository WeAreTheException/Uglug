extends Node
class_name MatchNetworkLookup

var root: MatchNetworkRoot = null


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func find_card_anywhere(runtime_id: String) -> CardRoot:
	var clean_id := runtime_id.strip_edges()

	if clean_id == "":
		return null

	if root == null:
		return null

	if root.deck_system_root != null:
		var card := find_card_in_hand(
			root.deck_system_root.player_one_hand,
			clean_id
		)

		if card != null:
			return card

		card = find_card_in_hand(
			root.deck_system_root.player_two_hand,
			clean_id
		)

		if card != null:
			return card

	if root.slots_root != null:
		return root.slots_root.find_card_by_runtime_id(clean_id)

	return null


func card_belongs_to_owner_hand(
	card: CardRoot,
	owner: SlotRow.SlotOwner
) -> bool:
	if root == null:
		return false

	if root.deck_system_root == null:
		return false

	var hand := root.deck_system_root.get_hand_for_owner(owner)

	if hand == null:
		return false

	return hand.has_card(card)


func find_card_in_hand(
	hand: PlayerHandRoot,
	runtime_id: String
) -> CardRoot:
	if hand == null:
		return null

	return hand.find_card_by_runtime_id(runtime_id)


func get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if root != null and root.turn_order_state != null:
		return root.turn_order_state.get_owner_name(owner)

	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
