extends Node2D
class_name CardMutationVisuals

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
