extends Node
class_name DeckDrawAnimationHandler

@export var card_draw_speed: float = 0.4
@export var flip_animation_name: String = "card_flip"

@export var draw_sfx: AudioStream
@export var volume_db: float = 0.0
@export var sfx_bus_name: String = "SFX"


var audio_player: AudioStreamPlayer


func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = volume_db


func prepare_card_start_position(card: Node2D, deck_root: Node2D) -> void:
	if card == null:
		return

	if deck_root == null:
		return

	card.global_position = deck_root.global_position


func add_card_to_hand_with_animation(target_hand: Node2D, card: Node2D) -> void:
	if target_hand == null:
		return

	if card == null:
		return

	if not target_hand.has_method("add_card_to_hand"):
		print("draw animation blocked: target_hand missing add_card_to_hand")
		return

	target_hand.add_card_to_hand(card, card_draw_speed)


func play_draw_animation(card: Node) -> void:
	if card == null:
		return

	_play_sfx(draw_sfx)

	var animation_player := card.get_node_or_null("AnimationPlayer") as AnimationPlayer

	if animation_player == null:
		return

	if not animation_player.has_animation(flip_animation_name):
		return

	animation_player.play(flip_animation_name)


func _play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return

	audio_player.stream = stream
	audio_player.play()
