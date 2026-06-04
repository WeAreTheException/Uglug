extends Node
class_name Hand_PlacementRelease

var card_spawner: Hand_CardSpawner = null
var hand_layout: Hand_Layout = null
var interaction_root: Hand_InteractionRoot = null
var sacrifice_selection: Hand_SacrificeSelection = null
var state_machine: Hand_StateMachine = null


func setup(
	source_card_spawner: Hand_CardSpawner,
	source_hand_layout: Hand_Layout,
	source_interaction_root: Hand_InteractionRoot,
	source_sacrifice_selection: Hand_SacrificeSelection,
	source_state_machine: Hand_StateMachine
) -> void:
	card_spawner = source_card_spawner
	hand_layout = source_hand_layout
	interaction_root = source_interaction_root
	sacrifice_selection = source_sacrifice_selection
	state_machine = source_state_machine


func release_primed_card_for_placement(card: CardRoot) -> void:
	if card == null:
		return

	if card_spawner == null:
		return

	if not card_spawner.is_card_in_hand(card):
		return

	card_spawner.remove_card(card)

	if interaction_root != null:
		interaction_root.consume_primed_card_silent(card)

	if sacrifice_selection != null:
		sacrifice_selection.clear_selection()

	if state_machine != null:
		state_machine.change_state(Hand_StateMachine.PLAY)

	if hand_layout != null:
		hand_layout.arrange_cards(card_spawner.get_cards())

	if interaction_root != null:
		interaction_root.refresh_hover_focus()
