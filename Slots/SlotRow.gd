extends Node2D
class_name SlotRow

enum SlotOwner {
	PLAYER,
	OPPONENT
}

@export var slot_owner: SlotOwner = SlotOwner.PLAYER


func get_slots() -> Array[Slot]:
	var slots: Array[Slot] = []

	for child in get_children():
		var slot := child as Slot
		if slot != null:
			slots.append(slot)

	slots.sort_custom(func(a: Slot, b: Slot) -> bool:
		return a.slot_index < b.slot_index
	)

	return slots
