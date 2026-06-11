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

	has_died = true

	if context.should_trigger_death_mutations:
		_notify_death_mutations()

	if animation_runner == null:
		print("die blocked: animation_runner missing")
		return

	die_started.emit(card)

	if death_audio != null:
		death_audio.play_detached()

	is_playing = true

	await animation_runner.play(card)

	is_playing = false

	if context.should_remove_from_board:
		_remove_card_from_board()

	die_finished.emit(card)

	if context.should_free_card and is_instance_valid(card):
		card.queue_free()


func _remove_card_from_board() -> void:
	if card == null:
		return

	if card.board_presence != null:
		card.board_presence.leave_slot(card)
		return

	var current_slot := card.get_current_slot()

	if current_slot != null and current_slot.current_card == card:
		current_slot.clear_card()


func _notify_death_mutations() -> void:
	if card == null:
		return

	if card.mutations == null:
		return

	card.mutations.notify_death()


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
