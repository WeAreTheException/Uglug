extends Node2D
class_name DeckRoot

@export var player_hand: Node2D
@export var opponent_hand: Node2D
@export var phase_manager: PhaseManager
@export var select_handler: SelectHandler
@export var combat_manager: CombatManager

@onready var input_listener: DeckInputListener = $DeckInputListener
@onready var counter: RichTextLabel = $RichTextLabel
@onready var deck_sprite: Sprite2D = $DeckImage
@onready var deck: DeckCount = $DeckCount
@onready var deck_view: DeckView = $DeckView
@onready var draw_handler: DeckDrawHandler = $DeckDrawHandler

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
		draw_handler.opponent_hand = opponent_hand
		draw_handler.phase_manager = phase_manager
		draw_handler.select_handler = select_handler
		draw_handler.combat_manager = combat_manager
