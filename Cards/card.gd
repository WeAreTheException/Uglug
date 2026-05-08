extends Node2D
	for mutation in additional_mutations:
		if mutation != null:
			mutation.on_damaged(self, attacker, amount)

	if current_health <= 0:
		kill()

func kill() -> void:
	if die_handler != null:
		die_handler.die()
		return

	if death_processed:
		return

	death_processed = true
	current_health = 0

	if stats != null:
		stats.update_health(current_health)

	for mutation in base_mutations:
		if mutation != null:
			mutation.on_death(self)

	for mutation in additional_mutations:
		if mutation != null:
			mutation.on_death(self)

	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	queue_free()

func _on_hovered(_listener) -> void:
	is_hovered = true

func _on_hovered_off(_listener) -> void:
	is_hovered = false

func _on_slot_entered(slot: NewSlots) -> void:
	overlapping_slot = slot

func _on_slot_exited(slot: NewSlots) -> void:
	if overlapping_slot == slot:
		overlapping_slot = null

func set_selected(value: bool) -> void:
	is_selected = value

	if scale_tween != null:
		scale_tween.kill()

	scale_tween = create_tween()

	if is_selected:
		scale_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.12)
	else:
		scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12)

func place_into_slot(slot: NewSlots) -> void:
	if slot == null:
		return

	if not slot.assign_card(self):
		return

	if current_slot != null and current_slot != slot:
		current_slot.clear_card()

	current_slot = slot

	if player_hand != null:
		if player_hand.has_method("remove_card_from_hand"):
			player_hand.remove_card_from_hand(self)

	animate_to_position(slot.global_position)

func animate_to_position(target_pos: Vector2) -> void:
	if move_tween != null:
		move_tween.kill()

	move_tween = create_tween()
	move_tween.tween_property(self, "global_position", target_pos, 0.18)

func apply_slot_owner(slot: NewSlots) -> void:
	if slot == null:
		return

	if slot.slot_owner == NewSlots.SlotOwner.PLAYER:
		card_owner = Owner.PLAYER
	else:
		card_owner = Owner.OPPONENT

func return_to_hand() -> void:
	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	if player_hand != null:
		if player_hand.has_method("add_card_to_hand"):
			player_hand.add_card_to_hand(self)

	set_selected(false)

func start_sacrifice_hint() -> void:
	sacrifice_hint_active = true
	sacrifice_hint_time = 0.0

func stop_sacrifice_hint() -> void:
	sacrifice_hint_active = false
	sacrifice_hint_time = 0.0
	rotation = 0.0

func update_sacrifice_hint(delta: float) -> void:
	if not sacrifice_hint_active:
		return

	sacrifice_hint_time += delta
	rotation = sin(sacrifice_hint_time * 8.0) * deg_to_rad(3.0)
