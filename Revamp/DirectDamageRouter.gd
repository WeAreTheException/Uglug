extends Node
class_name DirectDamageRouter

signal direct_damage_requested(
	attacker: CardRoot,
	attacker_owner: SlotRow.SlotOwner,
	target_slot: Slot,
	amount: int
)

@export var print_debug: bool = true


func request_direct_damage(
	attacker: CardRoot,
	attacker_owner: SlotRow.SlotOwner,
	target_slot: Slot,
	amount: int
) -> void:
	if attacker == null:
		return

	if target_slot == null:
		return

	if amount <= 0:
		return

	if print_debug:
		print(
			"DIRECT DAMAGE REQUESTED: ",
			_get_owner_name(attacker_owner),
			" amount ",
			amount
		)

	direct_damage_requested.emit(
		attacker,
		attacker_owner,
		target_slot,
		amount
	)


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
