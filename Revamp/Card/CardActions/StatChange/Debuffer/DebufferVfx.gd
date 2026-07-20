extends Node
class_name DebufferVFX

@export var aura_sprite: Sprite2D
@export var hide_on_ready: bool = true
@export var print_debug: bool = false


func _ready() -> void:
	if hide_on_ready:
		set_active(false)


func play(card: CardRoot = null) -> void:
	set_active(true, card)


func set_active(value: bool, card: CardRoot = null) -> void:
	if aura_sprite == null:
		return

	aura_sprite.visible = value

	if print_debug:
		var card_name := "unknown"

		if card != null:
			card_name = card.card_name

		print("DEBUFFER VFX | card=", card_name, " active=", value)
