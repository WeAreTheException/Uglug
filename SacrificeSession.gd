extends Node
class_name SacrificeSession

var primed_card: CardRoot = null
var required_worth: int = 0
var current_worth: int = 0
var is_active: bool = false


func start(card: CardRoot, cost: int) -> void:
	primed_card = card
	required_worth = cost
	current_worth = 0
	is_active = true


func clear() -> void:
	primed_card = null
	required_worth = 0
	current_worth = 0
	is_active = false


func set_current_worth(value: int) -> void:
	current_worth = value


func is_requirement_met() -> bool:
	return current_worth >= required_worth
