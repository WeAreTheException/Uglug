extends RefCounted
class_name HandInteractionCallbacksHelper

var root: Hand_InteractionRoot = null

func setup(source_root: Hand_InteractionRoot) -> void:
	root = source_root

func on_card_added(card: CardRoot) -> void:
	root.setup_helper.bind_card(root, root.callbacks, card)
	root.refresh_hover_focus()

func on_card_removed(card: CardRoot) -> void:
	if root.hover_focus != null:
		root.hover_focus.forget_card(card)
	if root.drag_controller != null:
		root.drag_controller.forget_card(card)
	if root.prime_controller != null:
		root.prime_controller.forget_card(card)
	if root.hand_layout != null:
		root.hand_layout.clear_primed_card()
	root.refresh_hover_focus()

func on_card_hovered(card: CardRoot) -> void:
	if root.hover_focus != null:
		root.hover_focus.add_hovered_card(card)

func on_card_unhovered(card: CardRoot) -> void:
	if root.hover_focus != null:
		root.hover_focus.remove_hovered_card(card)

func on_card_left_pressed(card: CardRoot) -> void:
	if root.drag_controller != null:
		root.drag_controller.handle_card_pressed(card)
	if root.prime_controller != null:
		root.prime_controller.handle_card_pressed(card)
	root.card_left_pressed.emit(card)

func on_card_left_released(card: CardRoot) -> void:
	if root.drag_controller != null:
		root.drag_controller.handle_card_released(card)
	root.card_left_released.emit(card)

func on_card_right_pressed(card: CardRoot) -> void:
	root.card_right_pressed.emit(card)

func on_card_primed(card: CardRoot) -> void:
	if root.hand_layout != null:
		root.hand_layout.set_primed_card(card)
	root.arrange_cards()
	root.card_primed.emit(card)

func on_card_unprimed(card: CardRoot) -> void:
	if root.hand_layout != null:
		root.hand_layout.clear_primed_card()
	root.arrange_cards()
	root.card_unprimed.emit(card)

func on_prime_state_changed(can_prime: bool, can_unprime: bool, text: String) -> void:
	root.prime_state_changed.emit(can_prime, can_unprime, text)
