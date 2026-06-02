extends Node2D
class_name SlotsRoot

signal slot_clicked(slot: Slot)

@export var player_row: SlotRow
@export var opponent_row: SlotRow

@export var card_scene: PackedScene
@export var spawned_card_parent: Node2D

@export var player_slot_1_card: CardData
@export var player_slot_2_card: CardData
@export var player_slot_3_card: CardData
@export var player_slot_4_card: CardData

@export var opponent_slot_1_card: CardData
@export var opponent_slot_2_card: CardData
@export var opponent_slot_3_card: CardData
@export var opponent_slot_4_card: CardData

@export var attack_animation_layer: Node2D

var player_slots: Array[Slot] = []
var opponent_slots: Array[Slot] = []


func _ready() -> void:
	player_slots = player_row.get_slots()
	opponent_slots = opponent_row.get_slots()

	_connect_slots(player_slots)
	_connect_slots(opponent_slots)

	var preset_handler := get_node_or_null("SlotPresetHandler") as SlotPresetHandler1

	if preset_handler != null:
		preset_handler.setup(self)
		preset_handler.spawn_all_presets()


func _connect_slots(slots: Array[Slot]) -> void:
	for slot in slots:
		if not slot.clicked.is_connected(_on_slot_clicked):
			slot.clicked.connect(_on_slot_clicked)


func _on_slot_clicked(slot: Slot) -> void:
	slot_clicked.emit(slot)


func get_preset_for_slot(slot: Slot) -> CardData:
	if slot == null:
		return null

	var owner := get_owner_of_slot(slot)

	if owner == SlotRow.SlotOwner.PLAYER:
		match slot.slot_index:
			1:
				return player_slot_1_card
			2:
				return player_slot_2_card
			3:
				return player_slot_3_card
			4:
				return player_slot_4_card

	if owner == SlotRow.SlotOwner.OPPONENT:
		match slot.slot_index:
			1:
				return opponent_slot_1_card
			2:
				return opponent_slot_2_card
			3:
				return opponent_slot_3_card
			4:
				return opponent_slot_4_card

	return null


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

func refresh_board_mutations() -> void:
	var all_slots: Array[Slot] = []
	all_slots.append_array(player_slots)
	all_slots.append_array(opponent_slots)

	for slot in all_slots:
		if slot == null:
			continue

		var card := slot.current_card

		if card == null:
			continue

		if card.mutations == null:
			continue

		for runtime in card.mutations.get_active_runtimes():
			if runtime == null:
				continue

			if runtime.mutation == null:
				continue

			runtime.mutation.refresh_board_effect(runtime)
