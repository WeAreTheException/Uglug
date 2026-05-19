extends Node
class_name DistantTargetPicker

var card: Card = null
var waiting := false
var chosen_slot: NewSlots = null


func _ready() -> void:
	card = _find_card_parent()


func pick_slot() -> NewSlots:
	waiting = true
	chosen_slot = null

	var tree := get_tree()
	if tree == null:
		waiting = false
		return null

	for slot in tree.get_nodes_in_group("slots"):
		var new_slot := slot as NewSlots
		if new_slot == null:
			continue

		if not new_slot.slot_clicked.is_connected(_on_slot_clicked):
			new_slot.slot_clicked.connect(_on_slot_clicked)

	while waiting:
		tree = get_tree()

		if tree == null:
			waiting = false
			_disconnect_slots()
			return null

		await tree.process_frame

	_disconnect_slots()
	return chosen_slot


func _on_slot_clicked(slot: NewSlots) -> void:
	if not waiting:
		return

	if card == null:
		return

	if card.current_slot == null:
		return

	if slot == null:
		return

	if card.owning_peer_id != multiplayer.get_unique_id():
		return

	if slot.slot_owner == card.current_slot.slot_owner:
		print("Distant blocked: cannot attack own side")
		return

	chosen_slot = slot
	waiting = false

	print(card.card_name, " chose Distant slot: ", slot.name)


func _disconnect_slots() -> void:
	var tree := get_tree()
	if tree == null:
		return

	for slot in tree.get_nodes_in_group("slots"):
		var new_slot := slot as NewSlots
		if new_slot == null:
			continue

		if new_slot.slot_clicked.is_connected(_on_slot_clicked):
			new_slot.slot_clicked.disconnect(_on_slot_clicked)


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
