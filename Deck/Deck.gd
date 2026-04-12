extends Area2D

const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 0.4

var player_deck = ["Ant", "Aviant", "Ant", "Samurant", "Ant"]
var card_database_reference
var card_scene = preload(CARD_SCENE_PATH)

@onready var player_hand = $"../PlayerHand"
@onready var card_manager = $"../CardManager"
@onready var deck_sprite = $Sprite2D
@onready var counter = $RichTextLabel

func _ready() -> void:
	player_deck.shuffle()
	card_database_reference = preload("res://Scripts/CardDatabase.gd")
	update_counter()

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		draw_card()

func draw_card() -> void:
	if player_deck.is_empty():
		return

	var card_drawn_name = player_deck.pop_front()
	update_counter()

	var new_card = card_scene.instantiate()

	var card_image_path = "res://Sprites/" + card_drawn_name + ".png"
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.get_node("Attack").text = str(card_database_reference.CARDS[card_drawn_name][0])
	new_card.get_node("Health").text = str(card_database_reference.CARDS[card_drawn_name][1])

	card_manager.add_child(new_card)
	new_card.global_position = global_position

	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

	if player_deck.is_empty():
		monitoring = false
		deck_sprite.visible = false
		if counter:
			counter.visible = false

func update_counter() -> void:
	if counter:
		counter.text = str(player_deck.size())
