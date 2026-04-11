extends Area2D

const COLLISION_MASK_DECK = 4
const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 0.4

var player_deck = []

var card_scene = preload(CARD_SCENE_PATH)

@onready var player_hand = $"../PlayerHand"
@onready var card_manager = $"../CardManager"
@onready var deck_sprite = $Sprite2D
@onready var counter = $RichTextLabel

func _ready():
	for i in range(20):
		player_deck.append("Ant")
	update_counter()
	
	randomize()
	player_deck.shuffle()
	update_counter()

func draw_card():
	if player_deck.is_empty():
		return

	var card_drawn = player_deck[0]
	player_deck.remove_at(0)

	update_counter()

	if player_deck.is_empty():
		monitoring = false   # disable clicking
		deck_sprite.visible = false
		if counter:
			counter.visible = false

	var new_card = card_scene.instantiate()
	card_manager.add_child(new_card)

	new_card.global_position = global_position

	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)

func update_counter():
	if counter:
		counter.text = str(player_deck.size())
