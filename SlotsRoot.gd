extends Node2D
class_name SlotsRoot

signal slot_clicked(slot: Slot)

@export var player_row: SlotRow
@export var opponent_row: SlotRow

var player_slots: Array[Slot] = []
var opponent_slots: Array[Slot] = []


func _ready() -> void:
	player_slots = player_row.get_slots()
	opponent_slots = opponent_row.get_slots()

	_connect_slots(player_slots)
	_connect_slots(opponent_slots)


func _connect_slots(slots: Array[Slot]) -> void:
	for slot in slots:
		if not slot.clicked.is_connected(_on_slot_clicked):
			slot.clicked.connect(_on_slot_clicked)


func _on_slot_clicked(slot: Slot) -> void:
	slot_clicked.emit(slot)


func get_slot(slot_owner: SlotRow.SlotOwner, slot_index: int) -> Slot:
	var slots := player_slots

	if slot_owner == SlotRow.SlotOwner.OPPONENT:
		slots = opponent_slots

	for slot in slots:
		if slot.slot_index == slot_index:
			return slot

	return null


func get_owner_of_slot(slot: Slot) -> SlotRow.SlotOwner:
	if player_slots.has(slot):
		return SlotRow.SlotOwner.PLAYER

	return SlotRow.SlotOwner.OPPONENT


func get_opposing_slot(slot: Slot) -> Slot:
	if slot == null:
		return null

	var owner := get_owner_of_slot(slot)
	var opposing_owner := SlotRow.SlotOwner.OPPONENT

	if owner == SlotRow.SlotOwner.OPPONENT:
		opposing_owner = SlotRow.SlotOwner.PLAYER

	return get_slot(opposing_owner, slot.slot_index)


func get_adjacent_enemy_slots(slot: Slot) -> Array[Slot]:
	var result: Array[Slot] = []

	if slot == null:
		return result

	var owner := get_owner_of_slot(slot)
	var enemy_owner := SlotRow.SlotOwner.OPPONENT

	if owner == SlotRow.SlotOwner.OPPONENT:
		enemy_owner = SlotRow.SlotOwner.PLAYER

	var left := get_slot(enemy_owner, slot.slot_index - 1)
	var right := get_slot(enemy_owner, slot.slot_index + 1)

	if left != null:
		result.append(left)

	if right != null:
		result.append(right)

	return result
