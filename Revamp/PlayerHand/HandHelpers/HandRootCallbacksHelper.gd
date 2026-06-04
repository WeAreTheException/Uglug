extends RefCounted
class_name HandRootCallbacksHelper

var root: PlayerHandRoot = null

func setup(source_root: PlayerHandRoot) -> void:
	root = source_root

func on_card_added(card: CardRoot) -> void:
	root.card_added.emit(card)

func on_card_removed(card: CardRoot) -> void:
	root.card_removed.emit(card)

func on_hand_changed() -> void:
	root.hand_changed.emit()
	root.arrange_cards()
	if root.interaction_root != null:
		root.interaction_root.refresh_hover_focus()
	root.emit_prime_state()

func on_card_primed(card: CardRoot) -> void:
	if root.sacrifice_selection != null:
		root.sacrifice_selection.set_primed_card(card)
	root.card_primed.emit(card)
	root.enter_sacrifice_state()
	root.emit_prime_state()

func on_card_unprimed(card: CardRoot) -> void:
	if root.sacrifice_selection != null:
		root.sacrifice_selection.set_primed_card(null)
	root.card_unprimed.emit(card)
	root.enter_play_state()
	root.emit_prime_state()

func on_hand_card_left_pressed(card: CardRoot) -> void:
	if root.sacrifice_selection != null:
		root.sacrifice_selection.handle_card_pressed(card)

func on_hand_card_right_pressed(card: CardRoot) -> void:
	if root.sacrifice_selection != null:
		root.sacrifice_selection.handle_card_right_pressed(card)

func on_sacrifice_selection_changed(cards: Array[CardRoot]) -> void:
	root.sacrifice_selection_changed.emit(cards)

func on_prime_state_changed(can_prime: bool, can_unprime: bool, text: String) -> void:
	root.prime_state_changed.emit(can_prime, can_unprime, text)

func on_hand_state_changed(state_name: String) -> void:
	root.hand_state_changed.emit(state_name)
	root.arrange_cards()
	root.emit_prime_state()
