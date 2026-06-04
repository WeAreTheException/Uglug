extends Node
class_name Hand_StateMachine

signal state_changed(state_name: String)

const IDLE := "Idle"
const PLAY := "Play"
const SACRIFICE := "Sacrifice"

@export var idle_state: Hand_IdleState
@export var play_state: Hand_PlayState
@export var sacrifice_state: Hand_SacrificeState

var hand_layout: Hand_Layout = null
var interaction_root: Hand_InteractionRoot = null
var sort_controller: Hand_SortController = null
var sacrifice_selection: Hand_SacrificeSelection = null

var current_state_name: String = ""


func setup(
	new_hand_layout: Hand_Layout,
	new_interaction_root: Hand_InteractionRoot,
	new_sort_controller: Hand_SortController,
	new_sacrifice_selection: Hand_SacrificeSelection
) -> void:
	hand_layout = new_hand_layout
	interaction_root = new_interaction_root
	sort_controller = new_sort_controller
	sacrifice_selection = new_sacrifice_selection

	if idle_state != null:
		idle_state.setup(self)

	if play_state != null:
		play_state.setup(self)

	if sacrifice_state != null:
		sacrifice_state.setup(self)


func change_state(state_name: String) -> void:
	if current_state_name == state_name:
		return

	_exit_current_state()

	current_state_name = state_name

	_enter_current_state()
	state_changed.emit(current_state_name)


func set_layout_mode(mode: Hand_Layout.LayoutMode) -> void:
	if hand_layout != null:
		hand_layout.set_layout_mode(mode)


func set_drag_enabled(value: bool) -> void:
	if interaction_root != null:
		interaction_root.set_drag_enabled(value)


func set_prime_select_enabled(value: bool) -> void:
	if interaction_root != null:
		interaction_root.set_prime_select_enabled(value)


func set_prime_action_enabled(value: bool) -> void:
	if interaction_root != null:
		interaction_root.set_prime_action_enabled(value)


func set_sort_enabled(value: bool) -> void:
	if sort_controller != null:
		sort_controller.set_sort_enabled(value)


func set_sacrifice_selection_enabled(value: bool) -> void:
	if sacrifice_selection == null:
		return

	if interaction_root != null:
		sacrifice_selection.set_primed_card(interaction_root.get_primed_card())

	sacrifice_selection.set_enabled(value)


func clear_prime_selection() -> void:
	if interaction_root != null:
		interaction_root.clear_prime_selection()


func clear_sacrifice_selection() -> void:
	if sacrifice_selection != null:
		sacrifice_selection.clear_selection()


func _enter_current_state() -> void:
	match current_state_name:
		IDLE:
			if idle_state != null:
				idle_state.enter()
		PLAY:
			if play_state != null:
				play_state.enter()
		SACRIFICE:
			if sacrifice_state != null:
				sacrifice_state.enter()


func _exit_current_state() -> void:
	match current_state_name:
		IDLE:
			if idle_state != null:
				idle_state.exit()
		PLAY:
			if play_state != null:
				play_state.exit()
		SACRIFICE:
			if sacrifice_state != null:
				sacrifice_state.exit()
