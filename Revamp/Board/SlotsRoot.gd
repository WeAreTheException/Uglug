extends Node2D
class_name SlotsRoot

signal slot_clicked(slot: Slot)
signal slot_hovered(slot: Slot)
signal slot_unhovered(slot: Slot)

@export var player_row: SlotRow
@export var opponent_row: SlotRow

@export var board_slot_registry: BoardSlotRegistry
@export var board_query: BoardQuery
@export var board_mutation_refresher: BoardMutationRefresher
@export var slot_preset_handler: SlotPresetHandler1
@export var attack_order_handler: AttackOrderHandler

@export var card_scene: PackedScene
@export var spawned_card_parent: Node2D
@export var attack_animation_layer: Node2D

@export var player_slot_1_card: CardData
@export var player_slot_2_card: CardData
@export var player_slot_3_card: CardData
@export var player_slot_4_card: CardData

@export var opponent_slot_1_card: CardData
@export var opponent_slot_2_card: CardData
@export var opponent_slot_3_card: CardData
@export var opponent_slot_4_card: CardData

@export var direct_damage_router: DirectDamageRouter

var player_slots: Array[Slot] = []
var opponent_slots: Array[Slot] = []


func _ready() -> void:
	_setup_registry()
	_setup_query()
	_setup_mutation_refresher()
	_setup_attack_order_handler()
	_setup_preset_handler()


func _setup_registry() -> void:
	if board_slot_registry == null:
		return

	board_slot_registry.setup(player_row, opponent_row)

	player_slots = board_slot_registry.get_slots_for_owner(SlotRow.SlotOwner.PLAYER)
	opponent_slots = board_slot_registry.get_slots_for_owner(SlotRow.SlotOwner.OPPONENT)

	if not board_slot_registry.slot_clicked.is_connected(_on_slot_clicked):
		board_slot_registry.slot_clicked.connect(_on_slot_clicked)

	if not board_slot_registry.slot_hovered.is_connected(_on_slot_hovered):
		board_slot_registry.slot_hovered.connect(_on_slot_hovered)

	if not board_slot_registry.slot_unhovered.is_connected(_on_slot_unhovered):
		board_slot_registry.slot_unhovered.connect(_on_slot_unhovered)


func _setup_query() -> void:
	if board_query != null:
		board_query.setup(board_slot_registry)


func _setup_mutation_refresher() -> void:
	if board_mutation_refresher != null:
		board_mutation_refresher.setup(board_query)


func _setup_attack_order_handler() -> void:
	if attack_order_handler != null:
		attack_order_handler.setup(self)


func _setup_preset_handler() -> void:
	if slot_preset_handler == null:
		return

	slot_preset_handler.setup(self)
	slot_preset_handler.spawn_all_presets()


func show_playable_slots(owner: SlotRow.SlotOwner) -> void:
	for slot in get_slots_for_owner(owner):
		if slot != null:
			slot.show_playable_feedback()

	var enemy_owner := get_enemy_owner(owner)

	for slot in get_slots_for_owner(enemy_owner):
		if slot != null:
			slot.show_idle_feedback()


func show_neutral_slots() -> void:
	for slot in get_all_slots():
		if slot != null:
			slot.show_idle_feedback()


func show_inactive_slots(owner: SlotRow.SlotOwner) -> void:
	for slot in get_slots_for_owner(owner):
		if slot != null:
			slot.show_inactive_feedback()


func clear_all_slot_feedback() -> void:
	for slot in get_all_slots():
		if slot != null:
			slot.clear_all_feedback()


func get_slots_for_owner(owner: SlotRow.SlotOwner) -> Array[Slot]:
	if board_query == null:
		return []

	return board_query.get_slots_for_owner(owner)


func get_all_slots() -> Array[Slot]:
	if board_query == null:
		return []

	return board_query.get_all_slots()


func get_empty_slots_for_owner(owner: SlotRow.SlotOwner) -> Array[Slot]:
	if board_query == null:
		return []

	return board_query.get_empty_slots_for_owner(owner)


func get_slot(owner: SlotRow.SlotOwner, slot_index: int) -> Slot:
	if board_query == null:
		return null

	return board_query.get_slot(owner, slot_index)


func get_owner_of_slot(slot: Slot) -> SlotRow.SlotOwner:
	if board_query == null:
		return SlotRow.SlotOwner.PLAYER

	return board_query.get_owner_of_slot(slot)


func get_enemy_owner(owner: SlotRow.SlotOwner) -> SlotRow.SlotOwner:
	if board_query == null:
		return SlotRow.SlotOwner.OPPONENT

	return board_query.get_enemy_owner(owner)


func get_opposing_slot(slot: Slot) -> Slot:
	if board_query == null:
		return null

	return board_query.get_opposing_slot(slot)


func get_adjacent_enemy_slots(slot: Slot) -> Array[Slot]:
	if board_query == null:
		return []

	return board_query.get_adjacent_enemy_slots(slot)


func get_first_empty_slot_in_order(
	owner: SlotRow.SlotOwner,
	left_to_right: bool
) -> Slot:
	if board_query == null:
		return null

	return board_query.get_first_empty_slot_in_order(owner, left_to_right)


func refresh_board_mutations() -> void:
	if board_mutation_refresher != null:
		board_mutation_refresher.refresh_board_mutations()


func get_preset_for_slot(slot: Slot) -> CardData:
	if slot == null:
		return null

	var owner := get_owner_of_slot(slot)

	if owner == SlotRow.SlotOwner.PLAYER:
		return _get_player_preset(slot.slot_index)

	return _get_opponent_preset(slot.slot_index)


func _get_player_preset(slot_index: int) -> CardData:
	match slot_index:
		1:
			return player_slot_1_card
		2:
			return player_slot_2_card
		3:
			return player_slot_3_card
		4:
			return player_slot_4_card

	return null


func _get_opponent_preset(slot_index: int) -> CardData:
	match slot_index:
		1:
			return opponent_slot_1_card
		2:
			return opponent_slot_2_card
		3:
			return opponent_slot_3_card
		4:
			return opponent_slot_4_card

	return null


func _on_slot_clicked(slot: Slot) -> void:
	slot_clicked.emit(slot)


func _on_slot_hovered(slot: Slot) -> void:
	slot_hovered.emit(slot)


func _on_slot_unhovered(slot: Slot) -> void:
	slot_unhovered.emit(slot)
