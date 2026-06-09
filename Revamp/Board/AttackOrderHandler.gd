extends Node
class_name AttackOrderHandler

signal attack_order_finished

@export var enable_debug_keys: bool = true
@export var player_debug_key: Key = KEY_P
@export var opponent_debug_key: Key = KEY_O
@export var player_left_to_right: bool = true
@export var opponent_left_to_right: bool = true

var slots_root: SlotsRoot = null
var is_running: bool = false

func setup(source_slots_root: SlotsRoot) -> void:
	slots_root = source_slots_root

func _input(event: InputEvent) -> void:
	if not enable_debug_keys:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == player_debug_key:
			run_attack_order(SlotRow.SlotOwner.PLAYER)
		if event.keycode == opponent_debug_key:
			run_attack_order(SlotRow.SlotOwner.OPPONENT)

func run_attack_order(owner: SlotRow.SlotOwner) -> void:
	if is_running or slots_root == null:
		return
	is_running = true
	var entries := _build_attack_entries(owner)
	_sort_attack_entries(entries, owner)
	for entry in entries:
		var card := entry["card"] as CardRoot
		if card != null:
			await card.perform_attack()
	is_running = false
	attack_order_finished.emit()

func _build_attack_entries(owner: SlotRow.SlotOwner) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for slot in slots_root.get_slots_for_owner(owner):
		if slot != null and slot.current_card != null:
			entries.append({
				"card": slot.current_card,
				"slot_index": slot.slot_index,
				"priority": _get_attack_priority(slot.current_card)
			})
	return entries

func _sort_attack_entries(entries: Array[Dictionary], owner: SlotRow.SlotOwner) -> void:
	var left_to_right := _get_left_to_right(owner)
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["priority"] != b["priority"]:
			return a["priority"] > b["priority"]
		return a["slot_index"] < b["slot_index"] if left_to_right else a["slot_index"] > b["slot_index"]
	)

func _get_left_to_right(owner: SlotRow.SlotOwner) -> bool:
	return opponent_left_to_right if owner == SlotRow.SlotOwner.OPPONENT else player_left_to_right

func _get_attack_priority(card: CardRoot) -> int:
	if card == null or card.functionality_root == null:
		return 0
	var mutations := card.functionality_root.mutations
	if mutations == null:
		return 0
	var total := 0
	for runtime in mutations.get_active_runtimes():
		if runtime != null and runtime.mutation != null:
			total += runtime.mutation.get_attack_priority(runtime)
	return total
