extends Node
class_name WorkerSpawnEffectHandler

@export var player_one_hand: PlayerHandRoot
@export var player_two_hand: PlayerHandRoot
@export var worker_source: WorkerSource

@export var respect_hand_limit_for_effect_spawns: bool = false
@export var print_debug: bool = true

var inheritance_helper := WorkerMutationInheritanceHelper.new()


func spawn_workers_for_card_owner(
	source_card: CardRoot,
	amount: int
) -> Array[CardRoot]:
	var spawned_workers: Array[CardRoot] = []

	if source_card == null:
		return spawned_workers

	if not is_instance_valid(source_card):
		return spawned_workers

	if amount <= 0:
		return spawned_workers

	var target_hand: PlayerHandRoot = _get_hand_for_card_owner(source_card)

	if target_hand == null:
		if print_debug:
			print("WorkerSpawnEffectHandler blocked: target hand missing")
		return spawned_workers

	for i: int in range(amount):
		if respect_hand_limit_for_effect_spawns and target_hand.is_full():
			if print_debug:
				print("WorkerSpawnEffectHandler blocked: hand full")
			break

		var worker_data: CardData = _get_worker_data()

		if worker_data == null:
			if print_debug:
				print("WorkerSpawnEffectHandler blocked: worker data missing")
			break

		var worker_card: CardRoot = target_hand.spawn_card_from_effect(
			worker_data,
			not respect_hand_limit_for_effect_spawns
		)

		if worker_card == null:
			if print_debug:
				print("WorkerSpawnEffectHandler blocked: worker spawn failed")
			continue

		inheritance_helper.apply_inherited_mutations(source_card, worker_card)
		spawned_workers.append(worker_card)

	return spawned_workers


func _get_worker_data() -> CardData:
	if worker_source == null:
		return null

	return worker_source.get_worker_card()


func _get_hand_for_card_owner(source_card: CardRoot) -> PlayerHandRoot:
	var owner: SlotRow.SlotOwner = _get_owner_for_card(source_card)

	if owner == SlotRow.SlotOwner.OPPONENT:
		return player_two_hand

	return player_one_hand


func _get_owner_for_card(source_card: CardRoot) -> SlotRow.SlotOwner:
	if source_card == null:
		return SlotRow.SlotOwner.PLAYER

	if source_card.slots_root == null:
		return SlotRow.SlotOwner.PLAYER

	var slot: Slot = source_card.get_current_slot()

	if slot == null:
		return SlotRow.SlotOwner.PLAYER

	return source_card.slots_root.get_owner_of_slot(slot)
