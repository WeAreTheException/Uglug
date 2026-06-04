extends Node
class_name BoardSlotRegistry

signal slot_clicked(slot: Slot)
signal slot_hovered(slot: Slot)
signal slot_unhovered(slot: Slot)

var player_slots: Array[Slot] = []
var opponent_slots: Array[Slot] = []


func setup(player_row: SlotRow, opponent_row: SlotRow) -> void:
	player_slots = _get_slots_from_row(player_row)
	opponent_slots = _get_slots_from_row(opponent_row)

	_connect_slots(player_slots)
	_connect_slots(opponent_slots)


func get_slots_for_owner(owner: SlotRow.SlotOwner) -> Array[Slot]:
	if owner == SlotRow.SlotOwner.OPPONENT:
		return opponent_slots.duplicate()

	return player_slots.duplicate()


func get_all_slots() -> Array[Slot]:
	var all_slots: Array[Slot] = []
	all_slots.append_array(player_slots)
	all_slots.append_array(opponent_slots)
	return all_slots


func has_slot(slot: Slot) -> bool:
	return player_slots.has(slot) or opponent_slots.has(slot)


func is_player_slot(slot: Slot) -> bool:
	return player_slots.has(slot)


func is_opponent_slot(slot: Slot) -> bool:
	return opponent_slots.has(slot)


func _get_slots_from_row(row: SlotRow) -> Array[Slot]:
	if row == null:
		return []

	return row.get_slots()


func _connect_slots(slots: Array[Slot]) -> void:
	for slot in slots:
		if slot == null:
			continue

		if not slot.clicked.is_connected(_on_slot_clicked):
			slot.clicked.connect(_on_slot_clicked)

		if not slot.hovered.is_connected(_on_slot_hovered):
			slot.hovered.connect(_on_slot_hovered)

		if not slot.unhovered.is_connected(_on_slot_unhovered):
			slot.unhovered.connect(_on_slot_unhovered)


func _on_slot_clicked(slot: Slot) -> void:
	slot_clicked.emit(slot)


func _on_slot_hovered(slot: Slot) -> void:
	slot_hovered.emit(slot)


func _on_slot_unhovered(slot: Slot) -> void:
	slot_unhovered.emit(slot)
