extends Node
class_name Hand_IdleState

var state_machine: Hand_StateMachine = null


func setup(source_state_machine: Hand_StateMachine) -> void:
	state_machine = source_state_machine


func enter() -> void:
	if state_machine == null:
		return

	state_machine.set_layout_mode(Hand_Layout.LayoutMode.IDLE)
	state_machine.set_drag_enabled(true)
	state_machine.set_prime_select_enabled(false)
	state_machine.set_prime_action_enabled(false)
	state_machine.set_sacrifice_selection_enabled(false)
	state_machine.set_sort_enabled(true)

	state_machine.clear_prime_selection()
	state_machine.clear_sacrifice_selection()


func exit() -> void:
	pass
