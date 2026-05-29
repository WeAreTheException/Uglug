extends Node
class_name AttackDebugInput

@export var attack: Attack

var is_hovering_card := false


func _ready() -> void:
	if attack == null:
		return

	if attack.card == null:
		return

	attack.card.hovered.connect(_on_card_hovered)
	attack.card.unhovered.connect(_on_card_unhovered)


func _input(event: InputEvent) -> void:
	if not is_hovering_card:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_A:
			attack.perform_debug_attack()


func _on_card_hovered(_card: CardRoot) -> void:
	is_hovering_card = true


func _on_card_unhovered(_card: CardRoot) -> void:
	is_hovering_card = false
