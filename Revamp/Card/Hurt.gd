extends Node
class_name Hurt

@export var animation_runner: HurtAnimationRunner

@export var enable_debug_key: bool = true
@export var debug_key: Key = KEY_H

var card: CardRoot = null

var is_hovered := false
var is_playing := false


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
			play_hurt()


func play_hurt() -> void:
	if is_playing:
		return

	if card == null:
		return

	if animation_runner == null:
		print("hurt blocked: animation_runner missing")
		return

	is_playing = true

	await animation_runner.play(card)

	is_playing = false


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovered = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovered = false
