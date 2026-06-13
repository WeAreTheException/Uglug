extends Node
class_name Hand_StateMachine

signal state_changed(state_name: String)

const IDLE := "Idle"
const PLAY := "Play"
const SACRIFICE := "Sacrifice"
const BLESSING := "Blessing"
const BUFF := "Buff"

@export var idle_state: Hand_IdleState
@export var play_state: Hand_PlayState
@export var sacrifice_state: Hand_SacrificeState
@export var blessing_state: Hand_BlessingState
@export var buff_state: Hand_BuffState

var current_state_name: String = ""


func setup(
	hand_layout: Hand_Layout,
	interaction_root: Hand_InteractionRoot,
	sort_controller: Hand_SortController,
	sacrifice_selection: Hand_SacrificeSelection
) -> void:
	if idle_state != null:
		idle_state.setup(
			hand_layout,
			interaction_root,
			sort_controller,
			sacrifice_selection
		)

	if play_state != null:
		play_state.setup(
			hand_layout,
			interaction_root,
			sort_controller,
			sacrifice_selection
		)

	if sacrifice_state != null:
		sacrifice_state.setup(
			hand_layout,
			interaction_root,
			sort_controller,
			sacrifice_selection
		)

	if blessing_state != null:
		blessing_state.setup(
			hand_layout,
			interaction_root,
			sort_controller,
			sacrifice_selection
		)

	if buff_state != null:
		buff_state.setup(
			hand_layout,
			interaction_root,
			sort_controller,
			sacrifice_selection
		)


func change_state(state_name: String) -> void:
	if current_state_name == state_name:
		return

	current_state_name = state_name

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

		BLESSING:
			if blessing_state != null:
				blessing_state.enter()

		BUFF:
			if buff_state != null:
				buff_state.enter()

	state_changed.emit(current_state_name)
