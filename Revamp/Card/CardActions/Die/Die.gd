extends Node
class_name Die

signal die_started(card: CardRoot)
signal die_finished(card: CardRoot)

@export var animation_runner: DieAnimationRunner
@export var death_audio: DeathAudio

@export var enable_debug_key: bool = true
@export var debug_key: Key = KEY_D

@export var free_card_after_death: bool = true

var card: CardRoot = null
var is_hovered := false
var is_playing := false
var is_dying := false
var has_died := false


func setup(source_card: CardRoot) -> void:
	card = source_card

	if card == null:
		return

	if not card.hovered.is_connected(_on_card_hovered):
		card.hovered.connect(_on_card_hovered)

	if not card.unhovered.is_connected(_on_card_unhovered):
		card.unhovered.connect(_on_card_unhovered)


func _input(event: InputEvent) -> void:
	if not enable_debug_key:
		return

	if not is_hovered:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == debug_key:
			play_die()


func play_die() -> void:
	var context := DeathContext.new()
	context.setup(card)
	context.should_free_card = free_card_after_death

	await die_with_context(context)


func die_with_context(context: DeathContext) -> void:
	if is_playing:
		return

	if has_died:
		return

	if card == null:
		return

	if context == null:
		return

	var should_return_to_hand := _should_return_revenant_to_hand(context)

	_start_death_state()

	die_started.emit(card)
	_notify_death_started(context)

	if death_audio != null:
		death_audio.play_detached()

	if animation_runner != null:
		await animation_runner.play(card)
	else:
		print("die blocked: animation_runner missing")

	if should_return_to_hand:
		_return_revenant_to_hand()
	elif context.should_remove_from_board:
		_remove_card_from_board()

	if context.should_trigger_death_mutations:
		_notify_death_mutations()

	is_playing = false
	is_dying = false

	_notify_death_finished(context)
	die_finished.emit(card)

	if should_return_to_hand:
		has_died = false
		return

	if context.should_free_card and is_instance_valid(card):
		card.queue_free()


func is_unavailable_for_combat() -> bool:
	if has_died:
		return true

	if is_dying:
		return true

	return false


func _start_death_state() -> void:
	has_died = true
	is_dying = true
	is_playing = true


func _should_return_revenant_to_hand(context: DeathContext) -> bool:
	if card == null:
		return false

	if context == null:
		return false

	if not card.is_revenant():
		return false

	return true


func _return_revenant_to_hand() -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	var target_hand: PlayerHandRoot = null

	if card.deck_system_root != null:
		target_hand = card.deck_system_root.get_hand_for_card_owner(card)

	if target_hand == null:
		print("REVENANT RETURN BLOCKED: target hand missing")
		return

	if card.board_presence != null and card.board_presence.is_on_board():
		card.board_presence.leave_slot(card)
	else:
		_remove_card_from_board()

	target_hand.return_existing_card_to_hand(card)

	print("REVENANT RETURNED TO HAND: ", card.card_name)


func _remove_card_from_board() -> void:
	if card == null:
		return

	if card.board_presence != null:
		card.board_presence.leave_slot(card)
		return

	var current_slot := card.get_current_slot()

	if current_slot != null and current_slot.current_card == card:
		current_slot.clear_card()


func _notify_death_started(context: DeathContext) -> void:
	if card == null:
		return

	if card.mutations == null:
		return

	card.mutations.notify_death_started(context)


func _notify_death_mutations() -> void:
	if card == null:
		return

	if card.mutations == null:
		return

	card.mutations.notify_death()


func _notify_death_finished(context: DeathContext) -> void:
	if card == null:
		return

	if card.mutations == null:
		return

	card.mutations.notify_death_finished(context)


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false

func play_network_die_visual() -> void:
	if card == null:
		return

	if animation_runner != null:
		await animation_runner.play(card)

	if card.is_revenant():
		var target_hand: PlayerHandRoot = null

		if card.deck_system_root != null:
			target_hand = card.deck_system_root.get_hand_for_card_owner(card)

		if card.board_presence != null:
			card.board_presence.leave_slot(card)

		if target_hand != null:
			target_hand.return_existing_card_to_hand(card)
			print("NETWORK REVENANT RETURNED TO HAND: ", card.card_name)
			return

	if card.board_presence != null:
		card.board_presence.leave_slot(card)

	if is_instance_valid(card):
		card.queue_free()
