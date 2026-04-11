extends Node2D

const HAND_COUNT = 4
const CARD_WIDTH = 200
const HAND_Y_POSITION = 890
const CARD_SCENE_PATH = "res://Scenes/card.tscn"

var player_hand: Array = []
var center_screen_x
var card_scene = preload(CARD_SCENE_PATH)

@onready var card_manager = $"../CardManager"

func _ready():
	center_screen_x = get_viewport_rect().size.x / 2
	
	for i in range(HAND_COUNT):
		var new_card = card_scene.instantiate()
		card_manager.add_child(new_card)
		new_card.name = "Card"
		add_card_to_hand(new_card)

# -------------------------
# ADD CARD
# -------------------------

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions()
	else:
		animate_card_to_position(card, card.hand_position)

# -------------------------
# REMOVE CARD
# -------------------------

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()

# -------------------------
# UPDATE POSITIONS
# -------------------------

func update_hand_positions():
	for i in range(player_hand.size()):
		var card = player_hand[i]
		var new_position = Vector2(
			calculate_card_position(i),
			HAND_Y_POSITION
		)
		
		card.hand_position = new_position
		animate_card_to_position(card, new_position)

# -------------------------
# CALCULATE POSITION
# -------------------------

func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

# -------------------------
# ANIMATION
# -------------------------

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)
