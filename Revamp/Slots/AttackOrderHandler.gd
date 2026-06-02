extends Node
class_name AttackOrderHandler

signal attack_order_finished

@export var slots_root: SlotsRoot

@export var enable_debug_key: bool = true
@export var debug_key: Key = KEY_T

@export var attacking_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER

var is_running := false


func _ready() -> void:
	if slots_root == null:
		slots_root = get_parent() as SlotsRoot


func _input(event: InputEvent) -> void:
	if not enable_debug_key:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == debug_key:
			run_attack_order(attacking_owner)


func run_attack_order(owner: SlotRow.SlotOwner) -> void:
	if is_running:
		return

	if slots_root == null:
		print("attack order blocked: slots_root missing")
		return

	is_running = true

	var entries := _build_attack_entries(owner)
	_sort_attack_entries(entries)

	for entry in entries:
		var card := entry["card"] as CardRoot

		if card == null:
			continue

		if card.attack == null:
			continue

		await card.attack.perform_attack()

	is_running = false
	attack_order_finished.emit()


func _build_attack_entries(owner: SlotRow.SlotOwner) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []

	var slots := slots_root.player_slots

	if owner == SlotRow.SlotOwner.OPPONENT:
		slots = slots_root.opponent_slots

	for slot in slots:
		if slot == null:
			continue

		if slot.current_card == null:
			continue

		var card := slot.current_card

		entries.append({
			"slot": slot,
			"card": card,
			"slot_index": slot.slot_index,
			"priority": _get_attack_priority(card)
		})

	return entries


func _sort_attack_entries(entries: Array[Dictionary]) -> void:
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_priority: int = a["priority"]
		var b_priority: int = b["priority"]

		if a_priority != b_priority:
			return a_priority > b_priority

		var a_slot_index: int = a["slot_index"]
		var b_slot_index: int = b["slot_index"]

		return a_slot_index < b_slot_index
	)


func _get_attack_priority(card: CardRoot) -> int:
	if card == null:
		return 0

	if card.mutations == null:
		return 0

	var total_priority := 0

	for runtime in card.mutations.get_active_runtimes():
		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		total_priority += runtime.mutation.get_attack_priority(runtime)

	return total_priority
