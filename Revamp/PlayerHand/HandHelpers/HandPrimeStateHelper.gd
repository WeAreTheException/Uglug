extends RefCounted
class_name HandPrimeStateHelper

var primed_card: CardRoot = null


func has_primed_card() -> bool:
	return primed_card != null


func set_primed_card(card: CardRoot) -> void:
	primed_card = card


func clear_primed_card() -> CardRoot:
	var old_card := primed_card
	primed_card = null
	return old_card


func consume_card(card: CardRoot) -> bool:
	if primed_card != card:
		return false

	primed_card = null
	return true
