extends Area2D

const CARD_SCENE_PATH = "res://NewCard.tscn"
const CARD_DRAW_SPEED = 0.4

@export var total_cards: int = 5
@export var player_hand: Node2D
@export var card_manager: Node2D

var card_scene = preload(CARD_SCENE_PATH)

@onready var deck_sprite = $Sprite2D
@onready var counter = $RichTextLabel

func _ready() -> void:
	input_pickable = true
	update_counter()

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		draw_card()

func draw_card() -> void:
	if total_cards <= 0:
		return

	if player_hand == null:
		push_error("Deck: player_hand not assigned in inspector")
		return

	if card_manager == null:
		push_error("Deck: card_manager not assigned in inspector")
		return

	total_cards -= 1
	update_counter()

	var new_card = card_scene.instantiate()
	new_card.player_hand = player_hand

	card_manager.add_child(new_card)
	new_card.global_position = global_position

	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)

	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("card_flip")

	if total_cards <= 0:
		monitoring = false
		deck_sprite.visible = false

func update_counter() -> void:
	counter.text = str(total_cards)
