extends Node
class_name DeckDrawHandler

const CARD_DRAW_SPEED = 0.4
const CARD_DATABASE = preload("res://Data/CardDatabase.gd")

var deck: DeckCount = null
var player_hand: Node2D = null
var card_manager: Node2D = null
var spawn_anchor: Node2D = null

func draw_card() -> void:
	if deck == null:
		return
	if player_hand == null:
		return
	if card_manager == null:
		return
	if spawn_anchor == null:
		return
	if deck.card_scene == null:
		return
	if not deck.consume_card():
		return

	var card_name := pick_card_name()
	if card_name == "":
		return

	var card_data: Dictionary = CARD_DATABASE.CARDS[card_name]

	var new_card = deck.card_scene.instantiate()
	new_card.player_hand = player_hand
	new_card.setup_card(card_name, card_data)

	card_manager.add_child(new_card)
	new_card.global_position = spawn_anchor.global_position
	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)

	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("card_flip")

func pick_card_name() -> String:
	var card_names := CARD_DATABASE.CARDS.keys()
	if card_names.is_empty():
		return ""

	return card_names[randi() % card_names.size()]
