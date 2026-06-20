extends Node
class_name DrawPileRoot

signal card_drawn(card_data: CardData)
signal card_entry_drawn(entry: Dictionary)
signal pile_changed(cards_left: int)
signal pile_empty

@export var instance: DrawPileInstance
@export var view: DrawPileView
@export var counter: DrawPileCounter


func _ready() -> void:
	_refresh_views()


func setup_with_cards(cards: Array[CardData]) -> void:
	if instance != null:
		instance.set_cards(cards)

	_refresh_views()


func setup_with_entries(entries: Array) -> void:
	if instance != null:
		instance.set_entries(entries)

	_refresh_views()


func draw_card() -> CardData:
	if instance == null:
		return null

	var card_data := instance.draw_card()

	if card_data == null:
		pile_empty.emit()
	else:
		card_drawn.emit(card_data)

	_refresh_views()
	return card_data


func draw_card_entry() -> Dictionary:
	if instance == null:
		return {}

	var entry := instance.draw_entry()

	if entry.is_empty():
		pile_empty.emit()
	else:
		card_entry_drawn.emit(entry)

	_refresh_views()
	return entry


func cards_left() -> int:
	if instance == null:
		return 0

	return instance.cards_left()


func clear_cards() -> void:
	if instance != null:
		instance.clear_cards()

	_refresh_views()


func _refresh_views() -> void:
	var count := cards_left()

	if view != null:
		view.set_cards_left(count)

	if counter != null:
		counter.set_count(count)

	pile_changed.emit(count)

func get_card_count() -> int:
	return cards_left()

func get_entries() -> Array:
	if instance == null:
		return []

	if instance.has_method("get_entries"):
		return instance.get_entries()

	return []

func restore_entries(entries: Array) -> void:
	setup_with_entries(entries)
