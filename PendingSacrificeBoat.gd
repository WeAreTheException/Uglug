extends Node
class_name PendingSacrificeBoat

signal pending_started(primed_card: CardRoot, cards: Array[CardRoot])
signal pending_undone(primed_card: CardRoot, cards: Array[CardRoot])
signal pending_taken(cards: Array[CardRoot])

@export var pending_layer: Node2D
@export var hide_cards_while_pending: bool = false
@export var move_cards_to_pending_layer: bool = false

var pending_primed_card: CardRoot = null
var pending_entries: Array[Dictionary] = []


func begin_pending(
	primed_card: CardRoot,
	entries: Array[Dictionary]
) -> Array[CardRoot]:
	if has_pending():
		return []

	pending_primed_card = primed_card
	pending_entries = entries.duplicate(true)

	var pending_cards: Array[CardRoot] = []

	for entry in pending_entries:
		var card := entry["card"] as CardRoot

		if card == null:
			continue

		_prepare_card_for_pending(card)
		pending_cards.append(card)

	pending_started.emit(pending_primed_card, pending_cards)

	return pending_cards


func undo_pending() -> Array[Dictionary]:
	var entries := pending_entries.duplicate(true)
	var cards: Array[CardRoot] = []

	for entry in entries:
		var card := entry["card"] as CardRoot

		if card == null:
			continue

		card.visible = true
		card.reset_sacrifice_feedback()
		cards.append(card)

	var old_primed := pending_primed_card

	_clear_pending()

	pending_undone.emit(old_primed, cards)

	return entries


func take_pending_cards() -> Array[CardRoot]:
	var cards: Array[CardRoot] = []

	for entry in pending_entries:
		var card := entry["card"] as CardRoot

		if card != null:
			cards.append(card)

	_clear_pending()

	pending_taken.emit(cards)

	return cards


func has_pending() -> bool:
	return pending_primed_card != null


func get_pending_primed_card() -> CardRoot:
	return pending_primed_card


func _prepare_card_for_pending(card: CardRoot) -> void:
	card.clear_hand_feedback()
	card.set_pending_sacrifice(true)

	if move_cards_to_pending_layer and pending_layer != null:
		_move_card_to_layer(card, pending_layer)

	card.visible = not hide_cards_while_pending


func _move_card_to_layer(card: CardRoot, target_layer: Node2D) -> void:
	if card == null:
		return

	if target_layer == null:
		return

	var saved_global_transform := card.global_transform

	if card.get_parent() != null:
		card.get_parent().remove_child(card)

	target_layer.add_child(card)
	card.global_transform = saved_global_transform


func _clear_pending() -> void:
	pending_primed_card = null
	pending_entries.clear()
