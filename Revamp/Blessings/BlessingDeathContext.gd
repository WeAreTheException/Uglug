extends RefCounted
class_name BlessingDeathContext

var card: CardRoot = null
var was_hand_sacrifice: bool = false
var was_discard: bool = false
var was_consumed: bool = false


func setup(
	source_card: CardRoot,
	source_was_hand_sacrifice: bool = false,
	source_was_discard: bool = false
) -> void:
	card = source_card
	was_hand_sacrifice = source_was_hand_sacrifice
	was_discard = source_was_discard
