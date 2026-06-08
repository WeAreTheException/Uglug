extends Node
class_name DrawPileRoot

signal card_drawn(card_data: CardData)
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


func cards_left() -> int:
	return 0 if instance == null else instance.cards_left()


func _refresh_views() -> void:
	var count := cards_left()
	if view != null:
		view.set_cards_left(count)
	if counter != null:
		counter.set_count(count)
	pile_changed.emit(count)
