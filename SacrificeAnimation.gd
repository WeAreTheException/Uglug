extends Node
class_name SacrificeAnimation

@export var hint_speed: float = 8.0
@export var hint_degrees: float = 3.0

var hinted_cards: Array[Card] = []
var hint_times: Dictionary = {}


func _process(delta: float) -> void:
	for card in hinted_cards.duplicate():
		if card == null or not is_instance_valid(card):
			hinted_cards.erase(card)
			hint_times.erase(card)
			continue

		var time := float(hint_times.get(card, 0.0))
		time += delta
		hint_times[card] = time

		card.rotation = sin(time * hint_speed) * deg_to_rad(hint_degrees)


func show_sacrifice_selected(card: Card) -> void:
	if card == null:
		return

	card.set_selected(true)


func show_sacrifice_unselected(card: Card) -> void:
	if card == null:
		return

	card.set_selected(false)


func show_sacrifice_hint(card: Card) -> void:
	if card == null:
		return

	if not hinted_cards.has(card):
		hinted_cards.append(card)

	hint_times[card] = 0.0


func hide_sacrifice_hint(card: Card) -> void:
	if card == null:
		return

	hinted_cards.erase(card)
	hint_times.erase(card)
	card.rotation = 0.0
