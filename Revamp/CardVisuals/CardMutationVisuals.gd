extends Node2D
class_name CardMutationVisuals

signal sigil_hovered(slot: SigilSlot)
signal sigil_unhovered(slot: SigilSlot)
signal sigil_right_clicked(slot: SigilSlot)
signal sigil_left_clicked(slot: SigilSlot)

@export var mutation_slot_1: SigilSlot
@export var mutation_slot_2: SigilSlot
@export var mutation_slot_3: SigilSlot

@export var greyed_out_alpha: float = 0.35


func display_runtimes(runtimes: Array[MutationRuntime]) -> void:
	clear_all()

	var slots := _get_mutation_slots()
	var display_count := mini(runtimes.size(), slots.size())

	for i in range(display_count):
		var runtime := runtimes[i]
		var slot := slots[i]

		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		if slot == null:
			continue

		_connect_slot(slot)
		slot.setup_runtime(runtime, greyed_out_alpha)


func clear_all() -> void:
	for slot in _get_mutation_slots():
		if slot == null:
			continue

		slot.clear()


func _get_mutation_slots() -> Array[SigilSlot]:
	return [
		mutation_slot_1,
		mutation_slot_2,
		mutation_slot_3
	]


func _connect_slot(slot: SigilSlot) -> void:
	if slot == null:
		return

	if not slot.hovered.is_connected(_on_slot_hovered):
		slot.hovered.connect(_on_slot_hovered)

	if not slot.unhovered.is_connected(_on_slot_unhovered):
		slot.unhovered.connect(_on_slot_unhovered)

	if not slot.right_clicked.is_connected(_on_slot_right_clicked):
		slot.right_clicked.connect(_on_slot_right_clicked)

	if not slot.left_clicked.is_connected(_on_slot_left_clicked):
		slot.left_clicked.connect(_on_slot_left_clicked)


func _on_slot_hovered(slot: SigilSlot) -> void:
	sigil_hovered.emit(slot)


func _on_slot_unhovered(slot: SigilSlot) -> void:
	sigil_unhovered.emit(slot)


func _on_slot_right_clicked(slot: SigilSlot) -> void:
	sigil_right_clicked.emit(slot)


func _on_slot_left_clicked(slot: SigilSlot) -> void:
	sigil_left_clicked.emit(slot)
