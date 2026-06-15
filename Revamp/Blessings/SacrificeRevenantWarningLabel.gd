extends Label
class_name SacrificeRevenantWarningLabel

@export var warning_text: String = "You are about to sacrifice your Revenant. It will not return."


func _ready() -> void:
	text = warning_text
	hide_warning()


func update_for_cards(cards: Array[CardRoot]) -> void:
	for card in cards:
		if card != null and card.is_revenant():
			show_warning()
			return

	hide_warning()


func hide_warning() -> void:
	visible = false


func show_warning() -> void:
	visible = true
