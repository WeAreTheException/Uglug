extends Node
class_name DeckDrawHandler

const CARD_DRAW_SPEED = 0.4

@export var card_database: CardDatabase

var deck: DeckCount = null
var player_hand: Node2D = null
var card_manager: Node2D = null
var spawn_anchor: Node2D = null
var phase_manager: PhaseManager = null

func draw_player_card() -> void:
	if phase_manager == null:
		print("Draw blocked: phase_manager is null")
		return

	if not phase_manager.is_player_draw_phase():
		print("Draw blocked: not in PLAYER_DRAW phase")
		return

	var success := draw_card_to_hand(player_hand, spawn_anchor, Card.Owner.PLAYER)

	if success:
		phase_manager.on_player_drew_card()

func draw_card_to_hand(target_hand: Node2D, target_spawn_anchor: Node2D, card_owner: int) -> bool:
	if deck == null:
		return false
	if target_hand == null:
		return false
	if card_manager == null:
		return false
	if target_spawn_anchor == null:
		return false
	if card_database == null:
		return false
	if deck.card_scene == null:
		return false

	if target_hand.is_hand_full():
		print("Hand full. Cannot draw.")
		return false

	var data: CardData = pick_card_data()
	if data == null:
		return false

	if not deck.consume_card():
		return false

	var new_card = deck.card_scene.instantiate()
	if new_card == null:
		print("Draw failed: could not instantiate card")
		return false

	new_card.player_hand = target_hand
	new_card.card_owner = card_owner

	if new_card.select_handler != null:
		new_card.select_handler.phase_manager = phase_manager

	card_manager.add_child(new_card)
	new_card.global_position = target_spawn_anchor.global_position

	new_card.setup_card(data)

	target_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)

	if new_card.has_node("AnimationPlayer"):
		new_card.get_node("AnimationPlayer").play("card_flip")

	return true

func pick_card_data() -> CardData:
	if card_database.cards.is_empty():
		return null

	return card_database.cards[randi() % card_database.cards.size()]
