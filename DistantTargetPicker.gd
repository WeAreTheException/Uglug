extends Node
class_name DistantTargetPicker

var card: Card = null
var waiting := false
var accepting_clicks := false
var chosen_slot: NewSlots = null


func _ready() -> void:
	card = _find_card_parent()


func pick_slot() -> NewSlots:
	waiting = true
	accepting_clicks = false
	chosen_slot = null

	if card == null:
		card = _find_card_parent()

	var tree := get_tree()

	if tree == null:
		waiting = false
		return null

	var slots := tree.get_nodes_in_group("slots")
	print("Distant picker found slots: ", slots.size())

	for slot in slots:
		var new_slot := slot as NewSlots

		if new_slot == null:
			continue

		print("Distant picker connecting to slot: ", new_slot.name)

		if not new_slot.slot_clicked.is_connected(_on_slot_clicked):
			new_slot.slot_clicked.connect(_on_slot_clicked)

	# Prevent the same click from being reused by the next Distant pick.
	await tree.process_frame
	accepting_clicks = true

	while waiting:
		tree = get_tree()

		if tree == null:
			waiting = false
			accepting_clicks = false
			_disconnect_slots()
			return null

		await tree.process_frame

	accepting_clicks = false
	_disconnect_slots()

	return chosen_slot


func _on_slot_clicked(slot: NewSlots) -> void:
	if not waiting:
		return

	if not accepting_clicks:
		return

	print("Distant picker received slot click: ", slot)

	if card == null:
		print("Distant click blocked: card null")
		return

	if card.current_slot == null:
		print("Distant click blocked: card has no current slot")
		return

	if slot == null:
		print("Distant click blocked: slot null")
		return

	if GDSync.get_client_id() != card.owning_peer_id:
		print("Distant click blocked: wrong player. card owner=", card.owning_peer_id, " local=", GDSync.get_client_id())
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
