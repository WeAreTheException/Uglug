extends Node
class_name Debuffer

signal debuffer_started(card: CardRoot)
signal debuffer_finished(card: CardRoot)

@export var feedback_handler: DebufferFeedbackHandler

@export var enable_debug_key: bool = true
@export var debug_key: Key = KEY_KP_5
@export var print_debug: bool = false

var card: CardRoot = null
var is_hovered: bool = false
var is_playing: bool = false
var is_aura_active: bool = false


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
			play_debuffer()


func play_debuffer() -> void:
	if is_playing:
		return

	if card == null:
		return

	is_playing = true
	debuffer_started.emit(card)

	set_aura_active(true)

	if print_debug:
		print("DEBUFFER PLAY | card=", card.card_name)

	is_playing = false
	debuffer_finished.emit(card)


func set_aura_active(value: bool) -> void:
	if is_aura_active == value:
		return

	is_aura_active = value

	if feedback_handler != null:
		feedback_handler.set_active(value, card)

	if print_debug:
		var card_name := "unknown"

		if card != null:
			card_name = card.card_name

		print("DEBUFFER AURA | card=", card_name, " active=", value)


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
