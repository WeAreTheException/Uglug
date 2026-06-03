extends Node
class_name Sacrifice

@export var animation_runner: SacrificeAnimationRunner
@export var debug_key: Key = KEY_S
@export var enable_debug_key: bool = true

var card: CardRoot = null
var is_anticipating := false


func _ready() -> void:
	card = _find_card_parent()


func _input(event: InputEvent) -> void:
	if not enable_debug_key:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == debug_key:
			start_anticipation()


func start_anticipation() -> void:
	if card == null:
		return

	if animation_runner == null:
		return

	is_anticipating = true
	animation_runner.play_anticipation(card)


func stop_anticipation() -> void:
	if card == null:
		return

	if animation_runner == null:
		return

	is_anticipating = false
	animation_runner.stop_anticipation(card)


func _find_card_parent() -> CardRoot:
	var current := get_parent()

	while current != null:
		var found_card := current as CardRoot

		if found_card != null:
			return found_card

		current = current.get_parent()

	return null
