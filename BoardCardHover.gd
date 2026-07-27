extends Node
class_name BoardCardHoverBinder

@export var slots_root: SlotsRoot
@export var tooltip_coordinator: MutationTooltipCoordinator

var hovered_slot: Slot = null
var hovered_card: CardRoot = null


func _ready() -> void:
	_connect_slots_root()


func _exit_tree() -> void:
	_clear_hovered_card()
	_disconnect_slots_root()


func _process(_delta: float) -> void:
	if hovered_slot == null:
		return

	if not is_instance_valid(hovered_slot):
		hovered_slot = null
		_clear_hovered_card()
		return

	_set_hovered_card(
		hovered_slot.current_card
	)


func _connect_slots_root() -> void:
	if slots_root == null:
		return

	if not slots_root.slot_hovered.is_connected(
		_on_slot_hovered
	):
		slots_root.slot_hovered.connect(
			_on_slot_hovered
		)

	if not slots_root.slot_unhovered.is_connected(
		_on_slot_unhovered
	):
		slots_root.slot_unhovered.connect(
			_on_slot_unhovered
		)


func _disconnect_slots_root() -> void:
	if slots_root == null:
		return

	if slots_root.slot_hovered.is_connected(
		_on_slot_hovered
	):
		slots_root.slot_hovered.disconnect(
			_on_slot_hovered
		)

	if slots_root.slot_unhovered.is_connected(
		_on_slot_unhovered
	):
		slots_root.slot_unhovered.disconnect(
			_on_slot_unhovered
		)


func _on_slot_hovered(slot: Slot) -> void:
	if slot == null:
		return

	hovered_slot = slot

	_set_hovered_card(
		slot.current_card
	)


func _on_slot_unhovered(slot: Slot) -> void:
	if hovered_slot != slot:
		return

	hovered_slot = null
	_clear_hovered_card()


func _set_hovered_card(
	card: CardRoot
) -> void:
	if (
		card != null
		and not is_instance_valid(card)
	):
		card = null

	if hovered_card == card:
		return

	var previous_card: CardRoot = hovered_card

	if (
		previous_card != null
		and is_instance_valid(previous_card)
	):
		previous_card.set_hover_focused(false)

	if tooltip_coordinator != null:
		tooltip_coordinator.clear_hovered_card(
			previous_card
		)

	hovered_card = card

	if hovered_card == null:
		return

	hovered_card.set_hover_focused(true)

	if tooltip_coordinator != null:
		tooltip_coordinator.set_hovered_card(
			hovered_card
		)


func _clear_hovered_card() -> void:
	_set_hovered_card(null)
