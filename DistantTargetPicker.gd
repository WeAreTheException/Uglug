extends Node
class_name DistantTargetPicker

@export var ready_visual: CanvasItem
@export var print_debug := true

var card: Card = null
var waiting := false
var accepting_clicks := false
var chosen_slot: NewSlots = null


func _ready() -> void:
	card = _find_card_parent()
	_set_ready_visual(false)


func pick_slot() -> NewSlots:
	waiting = true
	accepting_clicks = false
	chosen_slot = null

	if card == null:
		card = _find_card_parent()

	var tree := get_tree()

	if tree == null:
		waiting = false
		_set_ready_visual(false)
		return null

	var slots := tree.get_nodes_in_group("slots")

	for slot in slots:
		var new_slot := slot as NewSlots

		if new_slot == null:
			continue

		if not new_slot.slot_clicked.is_connected(_on_slot_clicked):
			new_slot.slot_clicked.connect(_on_slot_clicked)

	await tree.process_frame

	accepting_clicks = true
	_set_ready_visual(true)

	if print_debug:
		print("DISTANT READY: choose target slot")

	while waiting:
		tree = get_tree()

		if tree == null:
			waiting = false
			accepting_clicks = false
			_set_ready_visual(false)
			_disconnect_slots()
			return null

		await tree.process_frame

	accepting_clicks = false
	_set_ready_visual(false)
	_disconnect_slots()

	return chosen_slot


func _on_slot_clicked(slot: NewSlots) -> void:
	if not waiting:
		return

	if not accepting_clicks:
		return

	if card == null:
		return

	if card.current_slot == null:
		return

	if slot == null:
		return

	if GDSync.get_client_id() != card.owning_peer_id:
		return

	if slot.slot_owner == card.current_slot.slot_owner:
		print("Distant blocked: cannot attack own side")
		return

	chosen_slot = slot
	waiting = false

	if print_debug:
		print(card.card_name, " chose Distant slot: ", slot.name)


func _set_ready_visual(value: bool) -> void:
	if ready_visual == null:
		return

	if card == null:
		card = _find_card_parent()

	if card == null:
		ready_visual.visible = false
		return

	# Only the attacking card's owner should see the Distant prompt.
	if int(GDSync.get_client_id()) != card.owning_peer_id:
		ready_visual.visible = false
		return

	ready_visual.visible = value


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
