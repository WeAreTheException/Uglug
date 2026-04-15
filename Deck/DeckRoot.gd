extends Node2D
class_name DeckRoot

@export var input_listener: DeckInputListener
@export var counter: RichTextLabel
@export var deck_sprite: Sprite2D
@export var deck: DeckCount
@export var deck_view: DeckView
@export var draw_handler: DeckDrawHandler

@export var player_hand: Node2D
@export var card_manager: Node2D
@export var spawn_anchor: Node2D
@export var phase_manager: PhaseManager
@export var battle_scale: BattleScale
@export var select_handler: SelectHandler

func _ready() -> void:
	if input_listener != null:
		input_listener.draw_handler = draw_handler

	if deck_view != null:
		deck_view.deck = deck
		deck_view.counter = counter
		deck_view.deck_sprite = deck_sprite

	if draw_handler != null:
		draw_handler.deck = deck
		draw_handler.player_hand = player_hand
		draw_handler.card_manager = card_manager
		draw_handler.spawn_anchor = spawn_anchor
		draw_handler.phase_manager = phase_manager
		draw_handler.battle_scale = battle_scale
		draw_handler.select_handler = select_handler
