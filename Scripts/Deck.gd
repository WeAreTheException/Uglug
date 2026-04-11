extends Area2D

const COLLISION_MASK_DECK = 4
const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 0.4

var player_deck = ["Ant","Aviant","Ant","Samurant","Ant"]
var card_database_reference

var card_scene = preload(CARD_SCENE_PATH)

@onready var player_hand = $"../PlayerHand"
@onready var card_manager = $"../CardManager"
@onready var deck_sprite = $Sprite2D
@onready var counter = $RichTextLabel

func _ready(): 
	player_deck.shuffle()
	counter.text = str(player_deck.size())
	card_database_reference = preload("res://Scripts/CardDatabase.gd")

func draw_card():
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)

	update_counter()

	if player_deck.is_empty():
		monitoring = false   # disable clicking
		deck_sprite.visible = false
		if counter:
			counter.visible = false

	counter.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Sprites/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.get_node("Attack").text = str(card_database_reference.CARDS[card_drawn_name][0])
	new_card.get_node("Health").text = str(card_database_reference.CARDS[card_drawn_name	][1])

	
	card_manager.add_child(new_card)

	new_card.global_position = global_position

	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")

func update_counter():
	if counter:
		counter.text = str(player_deck.size())
