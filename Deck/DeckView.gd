extends Node
class_name DeckView

var deck: DeckCount = null
var counter: RichTextLabel = null
var deck_sprite: Sprite2D = null

func _process(_delta: float) -> void:
	if deck == null:
		return

	var amount_left := deck.cards_left()

	if counter != null:
		counter.text = str(amount_left)

	if deck_sprite != null:
		deck_sprite.visible = amount_left > 0
