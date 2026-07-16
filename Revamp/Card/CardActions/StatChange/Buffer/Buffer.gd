extends Node
class_name Buffer

signal buffer_started(card: CardRoot)
signal buffer_finished(card: CardRoot)

@export var enable_debug_key: bool = true
@export var debug_key: Key = KEY_KP_4
@export var print_debug: bool = false

var card: CardRoot = null
var is_hovered: bool = false
var is_playing: bool = false


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
			play_buffer()


func play_buffer() -> void:
	if is_playing:
		return

	if card == null:
		return

	is_playing = true
	buffer_started.emit(card)

	if print_debug:
		print("BUFFER PLAY | card=", card.card_name)

	is_playing = false
	buffer_finished.emit(card)


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
