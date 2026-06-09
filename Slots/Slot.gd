extends Node2D
class_name Slot

signal clicked(slot: Slot)
signal hovered(slot: Slot)
signal unhovered(slot: Slot)
signal card_assigned(slot: Slot, card: CardRoot)
signal card_cleared(slot: Slot, card: CardRoot)

@export var slot_index: int = 1

@export var slot_input: SlotInput
@export var slot_presence: SlotPresence
@export var slot_effects: SlotEffects
@export var slot_feedback: SlotFeedback
@export var card_anchor: Node2D

var current_card: CardRoot = null


func _ready() -> void:
	_setup_input()
	_setup_presence()
	_setup_effects()
	_setup_feedback()


func _setup_input() -> void:
	if slot_input == null:
		return

	slot_input.setup(self)

	if not slot_input.clicked.is_connected(_on_input_clicked):
		slot_input.clicked.connect(_on_input_clicked)

	if not slot_input.hovered.is_connected(_on_input_hovered):
		slot_input.hovered.connect(_on_input_hovered)

	if not slot_input.unhovered.is_connected(_on_input_unhovered):
		slot_input.unhovered.connect(_on_input_unhovered)


func _setup_presence() -> void:
	if slot_presence != null:
		slot_presence.setup(self)


func _setup_effects() -> void:
	if slot_effects != null:
		slot_effects.setup(self)


func _setup_feedback() -> void:
	if slot_feedback != null:
		slot_feedback.setup(self)


func is_empty() -> bool:
	if slot_presence == null:
		return current_card == null

	return slot_presence.is_empty()


func assign_card(card: CardRoot) -> bool:
	if card == null:
		return false

	if slot_presence == null:
		if current_card != null:
			return false

		current_card = card
	else:
		var success := slot_presence.assign_card(card)

		if not success:
			return false

		current_card = slot_presence.get_current_card()

	if slot_effects != null:
		slot_effects.on_card_entered(card)

	card_assigned.emit(self, card)

	return true


func clear_card() -> void:
	var removed_card := current_card

	if slot_effects != null and removed_card != null:
		slot_effects.on_card_left(removed_card)

	if slot_presence != null:
		slot_presence.clear_card()
		current_card = slot_presence.get_current_card()
	else:
		current_card = null

	if removed_card != null:
		card_cleared.emit(self, removed_card)


func get_current_card() -> CardRoot:
	return current_card


func add_slot_effect(effect: Resource) -> void:
	if slot_effects != null:
		slot_effects.add_effect(effect)


func remove_slot_effect(effect: Resource) -> void:
	if slot_effects != null:
		slot_effects.remove_effect(effect)


func clear_slot_effects() -> void:
	if slot_effects != null:
		slot_effects.clear_effects()


func refresh_slot_effects() -> void:
	if slot_effects != null:
		slot_effects.refresh_effects()


func get_card_anchor_global_position() -> Vector2:
	if card_anchor != null:
		return card_anchor.global_position

	return global_position


func show_playable_feedback() -> void:
	if slot_feedback != null:
		slot_feedback.show_playable()


func show_inactive_feedback() -> void:
	if slot_feedback != null:
		slot_feedback.show_inactive()


func show_idle_feedback() -> void:
	if slot_feedback != null:
		slot_feedback.show_idle()


func show_placement_preview(value: bool) -> void:
	if slot_feedback != null:
		slot_feedback.show_placement_preview(value)


func show_attack_preview(value: bool) -> void:
	if slot_feedback != null:
		slot_feedback.show_attack_preview(value)


func clear_preview_feedback() -> void:
	if slot_feedback != null:
		slot_feedback.clear_preview_feedback()


func clear_all_feedback() -> void:
	if slot_feedback != null:
		slot_feedback.clear_all_feedback()


func _on_input_clicked() -> void:
	clicked.emit(self)


func _on_input_hovered() -> void:
	hovered.emit(self)


func _on_input_unhovered() -> void:
	unhovered.emit(self)
