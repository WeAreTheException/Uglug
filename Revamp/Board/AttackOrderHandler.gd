extends Node
class_name AttackOrderHandler

signal attack_order_finished

@export var enable_debug_keys: bool = true
@export var player_debug_key: Key = KEY_P
@export var opponent_debug_key: Key = KEY_O

@export var player_left_to_right: bool = true
@export var opponent_left_to_right: bool = true

var slots_root: SlotsRoot = null
var is_running := false
var stop_requested := false


func setup(source_slots_root: SlotsRoot) -> void:
	slots_root = source_slots_root


func _input(event: InputEvent) -> void:
	if not enable_debug_keys:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == player_debug_key:
		run_attack_order(SlotRow.SlotOwner.PLAYER)

	if key_event.keycode == opponent_debug_key:
		run_attack_order(SlotRow.SlotOwner.OPPONENT)


func run_attack_order(slot_owner: SlotRow.SlotOwner) -> void:
	if is_running:
		return

	if slots_root == null:
		print("attack order blocked: slots_root missing")
		return

	is_running = true
	stop_requested = false

	var entries := _build_attack_entries(slot_owner)
	_sort_attack_entries(entries, slot_owner)

	for entry in entries:
		if stop_requested:
			break

		var card: CardRoot = _get_valid_card_from_entry(entry, slot_owner)

		if card == null:
			continue

		await card.attack.perform_attack()

	is_running = false
	attack_order_finished.emit()


func request_stop() -> void:
	stop_requested = true


func get_left_to_right(slot_owner: SlotRow.SlotOwner) -> bool:
	if slot_owner == SlotRow.SlotOwner.OPPONENT:
		return opponent_left_to_right

	return player_left_to_right


func _build_attack_entries(slot_owner: SlotRow.SlotOwner) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []

	for slot in slots_root.get_slots_for_owner(slot_owner):
		if slot == null:
			continue

		if slot.current_card == null:
			continue

		var card := slot.current_card

		if not _is_card_attack_ready(card):
			continue

		entries.append({
			"slot": slot,
			"slot_index": slot.slot_index,
			"priority": _get_attack_priority(card)
		})

	return entries


func _get_valid_card_from_entry(
	entry: Dictionary,
	expected_owner: SlotRow.SlotOwner
) -> CardRoot:
	if not entry.has("slot"):
		return null

	var slot := entry["slot"] as Slot

	if slot == null:
		return null

	if not is_instance_valid(slot):
		return null

	if slots_root.get_owner_of_slot(slot) != expected_owner:
		return null

	var card := slot.current_card

	if not _is_card_attack_ready(card):
		return null

	if card.get_current_slot() != slot:
		return null

	return card


func _is_card_attack_ready(card: CardRoot) -> bool:
	if card == null:
		print("ATTACK READY FAILED: card null")
		return false

	if not is_instance_valid(card):
		print("ATTACK READY FAILED: card invalid")
		return false

	if card.attack == null:
		print("ATTACK READY FAILED: attack missing | ", card.card_name)
		return false

	if card.die != null and card.die.is_unavailable_for_combat():
		print(
			"ATTACK READY FAILED: unavailable | ",
			card.card_name,
			" id=",
			card.get_runtime_id(),
			" has_died=",
			card.die.has_died,
			" is_dying=",
			card.die.is_dying
		)
		return false

	if card.stats != null and card.stats.is_dead():
		print(
			"ATTACK READY FAILED: dead stats | ",
			card.card_name,
			" id=",
			card.get_runtime_id(),
			" hp=",
			card.stats.get_health(),
			" max=",
			card.stats.get_max_health()
		)
		return false

	if card.get_current_slot() == null:
		print(
			"ATTACK READY FAILED: no slot | ",
			card.card_name,
			" id=",
			card.get_runtime_id()
		)
		return false

	return true


func _sort_attack_entries(
	entries: Array[Dictionary],
	slot_owner: SlotRow.SlotOwner
) -> void:
	var left_to_right := get_left_to_right(slot_owner)

	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_priority: int = a["priority"]
		var b_priority: int = b["priority"]

		if a_priority != b_priority:
			return a_priority > b_priority

		var a_slot_index: int = a["slot_index"]
		var b_slot_index: int = b["slot_index"]

		if left_to_right:
			return a_slot_index < b_slot_index

		return a_slot_index > b_slot_index
	)


func _get_attack_priority(card: CardRoot) -> int:
	if card == null:
		return 0

	if not is_instance_valid(card):
		return 0

	if card.mutations == null:
		return 0

	return card.mutations.get_attack_priority()

func get_attack_cards_in_order(slot_owner: SlotRow.SlotOwner) -> Array[CardRoot]:
	var cards: Array[CardRoot] = []

	if slots_root == null:
		return cards

	var entries := _build_attack_entries(slot_owner)
	_sort_attack_entries(entries, slot_owner)

	for entry in entries:
		var card := _get_valid_card_from_entry(entry, slot_owner)

		if card != null:
			cards.append(card)

	return cards
