extends RefCounted
class_name HandInteractionSetupHelper

func setup_children(root: Hand_InteractionRoot, callbacks: HandInteractionCallbacksHelper, prime_location: Node2D) -> void:
	if root.input_router != null:
		root.input_router.setup(root)
		_connect(root.input_router.card_left_pressed, Callable(callbacks, "on_card_left_pressed"))
		_connect(root.input_router.card_left_released, Callable(callbacks, "on_card_left_released"))
		_connect(root.input_router.card_right_pressed, Callable(callbacks, "on_card_right_pressed"))
	if root.hover_focus != null:
		root.hover_focus.setup(root)
	if root.drag_controller != null:
		root.drag_controller.setup(root)
	if root.prime_controller != null:
		root.prime_controller.setup(root, prime_location)
		_connect(root.prime_controller.card_primed, Callable(callbacks, "on_card_primed"))
		_connect(root.prime_controller.card_unprimed, Callable(callbacks, "on_card_unprimed"))
		_connect(root.prime_controller.prime_state_changed, Callable(callbacks, "on_prime_state_changed"))

func connect_spawner(root: Hand_InteractionRoot, callbacks: HandInteractionCallbacksHelper) -> void:
	if root.card_spawner == null:
		return
	_connect(root.card_spawner.card_added, Callable(callbacks, "on_card_added"))
	_connect(root.card_spawner.card_removed, Callable(callbacks, "on_card_removed"))
	for card in root.card_spawner.get_cards():
		bind_card(root, callbacks, card)

func bind_card(root: Hand_InteractionRoot, callbacks: HandInteractionCallbacksHelper, card: CardRoot) -> void:
	if card == null:
		return
	_connect(card.hovered, Callable(callbacks, "on_card_hovered"))
	_connect(card.unhovered, Callable(callbacks, "on_card_unhovered"))

func _connect(source_signal: Signal, target: Callable) -> void:
	if not source_signal.is_connected(target):
		source_signal.connect(target)
