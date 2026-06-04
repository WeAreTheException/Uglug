extends Node
class_name PlacementState

var is_placing: bool = false
var is_confirming: bool = false

var active_card: CardRoot = null
var active_owner: SlotRow.SlotOwner = SlotRow.SlotOwner.PLAYER
var preview_slot: Slot = null
var hovered_slot: Slot = null


func setup(_controller: PlacementController) -> void:
	pass


func start(card: CardRoot, owner: SlotRow.SlotOwner) -> void:
	is_placing = true
	is_confirming = false
	active_card = card
	active_owner = owner
	preview_slot = null
	hovered_slot = null


func set_preview_slot(slot: Slot) -> void:
	preview_slot = slot


func set_hovered_slot(slot: Slot) -> void:
	hovered_slot = slot


func has_active_card() -> bool:
	return active_card != null


func reset() -> void:
	is_placing = false
	is_confirming = false
	active_card = null
	preview_slot = null
	hovered_slot = null
