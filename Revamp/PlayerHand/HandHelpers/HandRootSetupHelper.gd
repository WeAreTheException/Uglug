extends RefCounted
class_name HandRootSetupHelper


func setup_root(root: PlayerHandRoot, callbacks: HandRootCallbacksHelper) -> void:
	_setup_spawner(root, callbacks)
	_setup_interaction(root, callbacks)
	_setup_sacrifice(root, callbacks)
	_setup_sort(root)
	_setup_state_machine(root, callbacks)
	_connect_buttons(root)


func _setup_spawner(root: PlayerHandRoot, cb: HandRootCallbacksHelper) -> void:
	var spawner := root.card_spawner

	if spawner == null:
		return

	spawner.configure(
		root.card_scene,
		root.starting_cards,
		root.hand_card_layer,
		root.max_hand_size,
		root.minimum_hand_size
	)

	_connect(spawner.card_added, Callable(cb, "on_card_added"))
	_connect(spawner.card_removed, Callable(cb, "on_card_removed"))
	_connect(spawner.hand_changed, Callable(cb, "on_hand_changed"))


func _setup_interaction(root: PlayerHandRoot, cb: HandRootCallbacksHelper) -> void:
	var interaction := root.interaction_root

	if interaction == null:
		return

	interaction.setup(
		root.card_spawner,
		root.hand_layout,
		root.hand_card_layer,
		root.drag_layer,
		root.prime_location
	)

	_connect(interaction.card_primed, Callable(cb, "on_card_primed"))
	_connect(interaction.card_unprimed, Callable(cb, "on_card_unprimed"))
	_connect(interaction.prime_state_changed, Callable(cb, "on_prime_state_changed"))
	_connect(interaction.card_left_pressed, Callable(cb, "on_hand_card_left_pressed"))
	_connect(interaction.card_right_pressed, Callable(cb, "on_hand_card_right_pressed"))


func _setup_sacrifice(root: PlayerHandRoot, cb: HandRootCallbacksHelper) -> void:
	if root.sacrifice_selection == null:
		return

	root.sacrifice_selection.setup(root.card_spawner)

	_connect(
		root.sacrifice_selection.hand_sacrifice_selection_changed,
		Callable(cb, "on_sacrifice_selection_changed")
	)


func _setup_sort(root: PlayerHandRoot) -> void:
	if root.sort_controller == null:
		return

	root.sort_controller.setup(root.card_spawner)


func _setup_state_machine(root: PlayerHandRoot, cb: HandRootCallbacksHelper) -> void:
	if root.state_machine == null:
		return

	root.state_machine.setup(
		root.hand_layout,
		root.interaction_root,
		root.sort_controller,
		root.sacrifice_selection
	)

	_connect(root.state_machine.state_changed, Callable(cb, "on_hand_state_changed"))


func _connect_buttons(root: PlayerHandRoot) -> void:
	if root.cost_sort != null:
		_connect(root.cost_sort.pressed, Callable(root, "request_sort_by_cost"))

	if root.mutation_sort != null:
		_connect(root.mutation_sort.pressed, Callable(root, "request_sort_by_mutation_count"))


func _connect(source_signal: Signal, target: Callable) -> void:
	if not source_signal.is_connected(target):
		source_signal.connect(target)
