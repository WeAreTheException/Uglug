extends Node
class_name Hand_IdleState

var hand_layout: Hand_Layout = null
var interaction_root: Hand_InteractionRoot = null
var sort_controller: Hand_SortController = null
var sacrifice_selection: Hand_SacrificeSelection = null


func setup(
	source_layout: Hand_Layout,
	source_interaction: Hand_InteractionRoot,
	source_sort: Hand_SortController,
	source_sacrifice_selection: Hand_SacrificeSelection
) -> void:
	hand_layout = source_layout
	interaction_root = source_interaction
	sort_controller = source_sort
	sacrifice_selection = source_sacrifice_selection


func enter() -> void:
	if hand_layout != null:
		hand_layout.set_layout_mode(Hand_Layout.LayoutMode.IDLE)

	if interaction_root != null:
		interaction_root.set_drag_enabled(true)
		interaction_root.set_prime_select_enabled(false)
		interaction_root.set_prime_action_enabled(false)
		interaction_root.clear_prime_selection()

	if sacrifice_selection != null:
		sacrifice_selection.set_enabled(false)
