extends Node2D
class_name DeckRoot

const CARD_SCENE_PATH = "res://NewCard.tscn"
const CARD_DRAW_SPEED = 0.4
const CARD_DATABASE = preload("res://Data/CardDatabase.gd")

@export var total_cards: int = 5
@export var player_hand: Node2D
@export var card_manager: Node2D

var card_scene: PackedScene = preload(CARD_SCENE_PATH)

@onready var input_listener: DeckInputListener = $DeckInputListener
@onready var counter: RichTextLabel = $RichTextLabel
@onready var deck_sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	input_listener.draw_handler = self
	update_view()

func draw_card() -> void:
	if total_cards <= 0:
		return

	if player_hand == null:
		push_error("Deck: player_hand not assigned.")
		return

	if card_manager == null:
		push_error("Deck: card_manager not assigned.")
		return

	total_cards -= 1
	update_view()

	var card_name := "Ant"
	var card_data: Dictionary = CARD_DATABASE.CARDS[card_name]

	var new_card = card_scene.instantiate()
	new_card.player_hand = player_hand
	new_card.setup_card(card_name, card_data)

	card_manager.add_child(new_card)
	new_card.global_position = global_position
	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)

	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("card_flip")

func update_view() -> void:
	if counter != null:
		counter.text = str(total_cards)

	if deck_sprite != null:
		deck_sprite.visible = total_cards > 0
