extends RefCounted
class_name HandLayoutExclusionHelper

var ignored_card: CardRoot = null
var primed_card: CardRoot = null


func should_include(card: CardRoot) -> bool:
	if card == null:
		return false

	if card == ignored_card:
		return false

	if card == primed_card:
		return false

	return true


func set_ignored_card(card: CardRoot) -> void:
	ignored_card = card


func clear_ignored_card() -> void:
	ignored_card = null


func set_primed_card(card: CardRoot) -> void:
	primed_card = card


func clear_primed_card() -> void:
	primed_card = null
