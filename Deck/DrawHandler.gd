extends Node
class_name DeckDrawHandler

const CARD_DRAW_SPEED = 0.4

@export var card_database: CardDatabase

var deck: DeckCount = null
var player_hand: Node2D = null
var card_manager: Node2D = null
var spawn_anchor: Node2D = null
var phase_manager: PhaseManager = null

func draw_card() -> void:
	if deck == null:
		return
	if player_hand == null:
		return
	if card_manager == null:
		return
	if spawn_anchor == null:
		return
	if card_database == null:
		return
	if deck.card_scene == null:
		return
	if phase_manager == null:
		print("Draw blocked: phase_manager is null")
		return
	if not phase_manager.is_player_draw_phase():
		print("Draw blocked: not in PLAYER_DRAW phase")
		return

	if player_hand.is_hand_full():
		print("Hand full. Cannot draw.")
		return

	var data: CardData = pick_card_data()
	if data == null:
		return

	if not deck.consume_card():
		return

	var new_card := deck.card_scene.instantiate() as Card
	if new_card == null:
		print("Draw failed: spawned scene is not a Card")
		return

	new_card.player_hand = player_hand
	new_card.phase_manager = phase_manager

	card_manager.add_child(new_card)
	new_card.global_position = spawn_anchor.global_position

	new_card.setup_card(data)

	player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)

	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("card_flip")

	phase_manager.on_player_drew_card()

func pick_card_data() -> CardData:
	if card_database.cards.is_empty():
		return null

	return card_database.cards[randi() % card_database.cards.size()]
