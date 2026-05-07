extends Node
class_name DieHandler

@export var die_anim: Node

var card: Card = null

func _ready() -> void:
	card = _find_card_parent()

func die() -> void:
	if card == null:
		return

	if card.death_processed:
		return

	card.death_processed = true
	card.current_health = 0

	if card.stats != null:
		card.stats.update_health(card.current_health)

	if card.quirk != null:
		card.quirk.on_death(card)

	if die_anim != null and die_anim.has_method("play_death"):
		await die_anim.play_death()

	if card.current_slot != null:
		card.current_slot.clear_card()
		card.current_slot = null

	card.queue_free()

func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card
		current = current.get_parent()

	return null
