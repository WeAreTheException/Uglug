extends Node2D
class_name CardMutationVisuals

signal sigil_hovered(slot: SigilSlot)
signal sigil_unhovered(slot: SigilSlot)
signal sigil_right_clicked(slot: SigilSlot)
signal sigil_left_clicked(slot: SigilSlot)

@export var base_sigil_container: Node2D
@export var additional_sigil_container: Node2D
@export var greyed_out_alpha: float = 0.35


func display_runtimes(runtimes: Array[MutationRuntime]) -> void:
	clear_all()

	if runtimes.is_empty():
		return

	for i in range(runtimes.size()):
		var runtime := runtimes[i]

		if runtime == null:
			continue

		if runtime.mutation == null:
			continue

		if i == 0:
			_set_sigil_in_container(
				base_sigil_container,
				0,
				runtime
			)
		else:
			_set_sigil_in_container(
				additional_sigil_container,
				i - 1,
				runtime
			)


func clear_all() -> void:
	_clear_container(base_sigil_container)
	_clear_container(additional_sigil_container)


func _set_sigil_in_container(
	container: Node2D,
	index: int,
	runtime: MutationRuntime
) -> void:
	if container == null:
		return

	if index < 0:
		return

	if index >= container.get_child_count():
		return

	var slot := container.get_child(index) as SigilSlot

	if slot == null:
		return

	_connect_slot(slot)
	slot.setup_runtime(runtime, greyed_out_alpha)


func _clear_container(container: Node2D) -> void:
	if container == null:
		return

	for child in container.get_children():
		var slot := child as SigilSlot

		if slot == null:
			continue

		slot.clear()


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
	print("CARD MUTATION VISUALS GOT HOVER: ", slot.get_mutation_name())
	sigil_hovered.emit(slot)


func _on_slot_unhovered(slot: SigilSlot) -> void:
	print("CARD MUTATION VISUALS GOT UNHOVER: ", slot.get_mutation_name())
	sigil_unhovered.emit(slot)


func _on_slot_right_clicked(slot: SigilSlot) -> void:
	print("CARD MUTATION VISUALS GOT RIGHT CLICK: ", slot.get_mutation_name())
	sigil_right_clicked.emit(slot)


func _on_slot_left_clicked(slot: SigilSlot) -> void:
	print("CARD MUTATION VISUALS GOT LEFT CLICK: ", slot.get_mutation_name())
	sigil_left_clicked.emit(slot)
