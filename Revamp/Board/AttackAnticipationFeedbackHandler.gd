extends Node
class_name AttackAnticipationFeedbackHandler

@export var slots_root: SlotsRoot
@export var jitter_offset: float = 2.0
@export var jitter_time: float = 0.045

var active_tweens: Dictionary = {}


func start_for_owner(owner: SlotRow.SlotOwner) -> void:
	stop_for_owner(owner)

	if slots_root == null:
		return

	for slot in slots_root.get_slots_for_owner(owner):
		if slot == null:
			continue

		if slot.current_card == null:
			continue

		_start_card(slot.current_card)


func stop_for_owner(owner: SlotRow.SlotOwner) -> void:
	if slots_root == null:
		return

	for slot in slots_root.get_slots_for_owner(owner):
		if slot == null:
			continue

		if slot.current_card == null:
			continue

		_stop_card(slot.current_card)


func stop_all() -> void:
	var cards := active_tweens.keys()

	for card in cards:
		_stop_card(card as CardRoot)


func _start_card(card: CardRoot) -> void:
	if card == null:
		return

	if active_tweens.has(card):
		return

	var base_position := card.position
	var tween := create_tween()
	tween.set_loops()

	active_tweens[card] = {
		"tween": tween,
		"base_position": base_position
	}

	tween.tween_property(
		card,
		"position",
		base_position + Vector2(jitter_offset, 0),
		jitter_time
	)

	tween.tween_property(
		card,
		"position",
		base_position + Vector2(-jitter_offset, 0),
		jitter_time
	)

	tween.tween_property(
		card,
		"position",
		base_position,
		jitter_time
	)


func _stop_card(card: CardRoot) -> void:
	if card == null:
		return

	if not active_tweens.has(card):
		return

	var data: Dictionary = active_tweens[card]
	var tween := data["tween"] as Tween
	var base_position := data["base_position"] as Vector2

	if tween != null:
		tween.kill()

	card.position = base_position
	active_tweens.erase(card)
