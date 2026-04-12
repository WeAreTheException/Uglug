extends Node
class_name DeckView

var deck: Deck = null
var counter: RichTextLabel = null
var deck_sprite: Sprite2D = null

func _process(_delta: float) -> void:
	if deck == null:
		return

	if counter != null:
		counter.text = str(deck.total_cards)

	if deck_sprite != null:
		deck_sprite.visible = deck.total_cards > 0
