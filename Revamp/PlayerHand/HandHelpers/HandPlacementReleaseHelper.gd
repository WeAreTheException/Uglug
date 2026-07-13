extends RefCounted
class_name HandPlacementReleaseHelper


func release_primed_card_for_placement(
	card: CardRoot,
	card_spawner: Hand_CardSpawner,
	hand_layout: Hand_Layout,
	interaction_root: Hand_InteractionRoot,
	sacrifice_selection: Hand_SacrificeSelection,
	state_machine: Hand_StateMachine
) -> void:
	if card == null:
		return

	if card_spawner == null:
		return

	if not card_spawner.is_card_in_hand(card):
		return

	_kill_hand_layout_tween(card, hand_layout)

	card.clear_hand_feedback()

	card_spawner.remove_card(card)

	if interaction_root != null:
		interaction_root.consume_primed_card_silent(card)

	if sacrifice_selection != null:
		sacrifice_selection.clear_selection()

	if state_machine != null:
		state_machine.change_state(Hand_StateMachine.PLAY)

	if interaction_root != null:
		interaction_root.refresh_hover_focus()


func _kill_hand_layout_tween(
	card: CardRoot,
	hand_layout: Hand_Layout
) -> void:
	if hand_layout == null:
		return

	hand_layout.clear_ignored_card()
	hand_layout.clear_primed_card()

	if hand_layout.layout_tweener == null:
		return

	hand_layout.layout_tweener.kill_card_tween(card)
