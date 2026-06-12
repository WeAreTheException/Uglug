extends Node
class_name DirectDamageRouter

signal direct_damage_requested(
	attacker: CardRoot,
	attacker_owner: SlotRow.SlotOwner,
	target_slot: Slot,
	amount: int
)

signal direct_damage_applied(
	attacker_owner: SlotRow.SlotOwner,
	amount: int,
	score: int
)

@export var score_state: MatchScoreState
@export var slots_root: SlotsRoot
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

	if slots_root != null:
		slots_root.show_direct_damage_feedback(target_slot)

	if score_state == null:
		return

	score_state.apply_direct_damage(attacker_owner, amount)

	direct_damage_applied.emit(
		attacker_owner,
		amount,
		score_state.score
	)


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	if owner == SlotRow.SlotOwner.PLAYER:
		return "P1"

	return "P2"
