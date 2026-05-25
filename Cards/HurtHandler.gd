extends Node
class_name HurtHandler

@export var hurt_anim: Node

var card: Card = null


func _ready() -> void:
	card = _find_card_parent()


func take_damage(amount: int, attacker: Card = null) -> void:
	if card == null:
		return

	if card.death_processed:
		return

	card.current_health -= amount

	if card.current_health < 0:
		card.current_health = 0

	if hurt_anim != null and hurt_anim.has_method("play_hurt"):
		hurt_anim.play_hurt()

	var mutations := card.get_all_mutations()

	for mutation in mutations:
		if mutation != null and mutation.has_method("on_damaged"):
			mutation.on_damaged(card, attacker, amount)

	if card.current_health <= 0:
		if card.die_handler != null:
			card.die_handler.die()
		else:
			card.kill()


func _find_card_parent() -> Card:
	var current := get_parent()

	while current != null:
		if current is Card:
			return current as Card

		current = current.get_parent()

	return null
