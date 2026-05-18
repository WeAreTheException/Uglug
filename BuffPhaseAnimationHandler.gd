extends Node
class_name BuffPhaseWiggleHandler

@export var phase_manager: PhaseManager
@export var player_hand: NewPlayerHand

var wiggle_active: bool = false
var currently_wiggling: Array[Card] = []


func _ready() -> void:
	if phase_manager == null:
		phase_manager = get_tree().current_scene.find_child("PhaseManager", true, false) as PhaseManager

	if player_hand == null:
		player_hand = get_tree().current_scene.find_child("NewPlayerHand", true, false) as NewPlayerHand

	if phase_manager != null:
		if not phase_manager.phase_changed.is_connected(_on_phase_changed):
			phase_manager.phase_changed.connect(_on_phase_changed)

	set_process(true)


func _process(_delta: float) -> void:
	if wiggle_active:
		update_wiggles()


func _on_phase_changed(phase_name: String) -> void:
	if phase_name == "Buff":
		start_wiggle()
	else:
		stop_wiggle()


func start_wiggle() -> void:
	wiggle_active = true
	update_wiggles()


func stop_wiggle() -> void:
	wiggle_active = false

	for card in currently_wiggling:
		if card != null and is_instance_valid(card):
			card.stop_sacrifice_hint()

	currently_wiggling.clear()

	var select_handler := get_tree().current_scene.find_child("SelectHandler", true, false) as SelectHandler

	if select_handler != null:
		select_handler.clear_buff_selection()
	else:
		if SelectHandler.selected_card != null:
			SelectHandler.selected_card.set_selected(false)

		SelectHandler.selected_card = null


func update_wiggles() -> void:
	var selected_card := SelectHandler.selected_card
	var valid_cards := _get_player_hand_cards()

	for card in valid_cards:
		if card == null:
			continue

		var should_wiggle := card != selected_card

		if should_wiggle:
			if not currently_wiggling.has(card):
				card.start_sacrifice_hint()
				currently_wiggling.append(card)
		else:
			if currently_wiggling.has(card):
				card.stop_sacrifice_hint()
				currently_wiggling.erase(card)

	for card in currently_wiggling.duplicate():
		if card == null or not is_instance_valid(card) or not valid_cards.has(card):
			if card != null and is_instance_valid(card):
				card.stop_sacrifice_hint()

			currently_wiggling.erase(card)


func _get_player_hand_cards() -> Array[Card]:
	var cards: Array[Card] = []

	if player_hand == null:
		return cards

	for child in player_hand.get_children():
		if child is Card:
			var card := child as Card

			if card.card_owner == Card.Owner.PLAYER and card.current_slot == null:
				cards.append(card)

	return cards
