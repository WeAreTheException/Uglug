extends Node
class_name BackInHandDeathVisualHandler

@export var die_anim: Node

var card: Card = null


func _ready() -> void:
	card = _find_card_parent()


func play_visual_death() -> void:
	if card == null:
		return

	card.current_health = 0

	var stats := card.find_child("Stats", true, false)

	if stats != null and stats.has_method("update_health"):
		stats.update_health(card.current_health)

	if die_anim != null and die_anim.has_method("play_death"):
		await die_anim.play_death()


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
