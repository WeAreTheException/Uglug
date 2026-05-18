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

	var stats := card.find_child("Stats", true, false)

	if stats != null and stats.has_method("update_health"):
		stats.update_health(card.current_health)

	var mutations := card.get_all_mutations()

	for mutation in mutations:
		if mutation != null:
			mutation.on_death(card)

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
