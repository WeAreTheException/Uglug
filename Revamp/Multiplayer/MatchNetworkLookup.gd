extends Node
class_name MatchNetworkLookup

@export var enable_lookup_debug := false
@export var lookup_debug_key: Key = KEY_L

var root: MatchNetworkRoot = null


func setup(source_root: MatchNetworkRoot) -> void:
	root = source_root


func handle_debug_input(key_event: InputEventKey) -> void:
	if not enable_lookup_debug:
		return

	if key_event.keycode == lookup_debug_key:
		_run_lookup_debug()


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


func _run_lookup_debug() -> void:
	if root == null:
		print("LOOKUP DEBUG FAILED: root missing")
		return

	if root.deck_system_root == null:
		print("LOOKUP DEBUG FAILED: deck_system_root missing")
		return

	var hand := root.deck_system_root.player_one_hand

	if hand == null:
		print("LOOKUP DEBUG FAILED: P1 hand missing")
		return

	if hand.card_spawner == null:
		print("LOOKUP DEBUG FAILED: P1 card_spawner missing")
		return

	var cards := hand.card_spawner.get_cards()

	if cards.is_empty():
		print("LOOKUP DEBUG FAILED: P1 hand empty")
		return

	var first_card: CardRoot = cards[0]
	var runtime_id := first_card.get_runtime_id()
	var found_card := find_card_anywhere(runtime_id)

	print("LOOKUP DEBUG ID: ", runtime_id)
	print("LOOKUP DEBUG FOUND: ", found_card == first_card)
