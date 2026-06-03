extends Node
class_name HandPrimeController

signal card_primed(card: CardRoot)
signal card_unprimed(card: CardRoot)

@export var hand: PlayerHandRoot
@export var selection_controller: HandSelectionController

@export var move_time: float = 0.18
@export var primed_z_index: int = 150

var primed_card: CardRoot = null


func _ready() -> void:
	if hand == null:
		hand = get_parent() as PlayerHandRoot


func can_prime_selected_card() -> bool:
	if hand == null:
		return false

	if hand.current_hand_mode != PhaseManager.HandMode.HAND_ACTIVE:
		return false

	if selection_controller == null:
		return false

	var selected_card := selection_controller.get_selected_card()

	if selected_card == null:
		return false

	if primed_card != null:
		return false

	return hand.is_card_in_hand(selected_card)


func can_unprime() -> bool:
	return primed_card != null


func toggle_prime() -> void:
	if primed_card != null:
		unprime_card()
	else:
		prime_selected_card()


func prime_selected_card() -> void:
	if not can_prime_selected_card():
		return

	var selected_card := selection_controller.get_selected_card()

	primed_card = selected_card

	if selection_controller != null:
		selection_controller.clear_selected_card()

	primed_card.z_index = primed_z_index

	if hand != null and hand.hand_layout != null:
		hand.hand_layout.set_primed_card(primed_card)

	if hand != null:
		hand.arrange_cards()

	if hand != null and hand.prime_anchor != null:
		_move_card_to_position(
			primed_card,
			hand.prime_anchor.global_position
		)

	card_primed.emit(primed_card)


func unprime_card() -> void:
	if primed_card == null:
		return

	var old_card := primed_card

	if hand != null and hand.hand_layout != null:
		hand.hand_layout.clear_primed_card()

	primed_card = null

	if hand != null:
		hand.arrange_cards()

	card_unprimed.emit(old_card)


func get_primed_card() -> CardRoot:
	return primed_card


func _move_card_to_position(
	card: CardRoot,
	target_position: Vector2
) -> void:
	if card == null:
		return

	var tween := card.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		card,
		"global_position",
		target_position,
		move_time
	)

	tween.parallel().tween_property(
		card,
		"rotation_degrees",
		0.0,
		move_time
	)
