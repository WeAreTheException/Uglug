extends Node
class_name MutationButtonHoverBinder


@export var mutation_button: Button
@export var evolution_button_handler: EvolutionButtonHandler
@export var tooltip_coordinator: MutationTooltipCoordinator

var is_hovered: bool = false
var shown_mutation: Mutation = null


func _ready() -> void:
	_connect_button()


func _exit_tree() -> void:
	if tooltip_coordinator != null:
		tooltip_coordinator.clear_button_hover_mutation()


func _process(_delta: float) -> void:
	if not is_hovered:
		return

	var active_mutation: Mutation = (
		_get_active_mutation()
	)

	if active_mutation == shown_mutation:
		return

	_refresh_tooltip()


func _connect_button() -> void:
	if mutation_button == null:
		return

	if not mutation_button.mouse_entered.is_connected(
		_on_mouse_entered
	):
		mutation_button.mouse_entered.connect(
			_on_mouse_entered
		)

	if not mutation_button.mouse_exited.is_connected(
		_on_mouse_exited
	):
		mutation_button.mouse_exited.connect(
			_on_mouse_exited
		)


func _on_mouse_entered() -> void:
	is_hovered = true
	_refresh_tooltip()


func _on_mouse_exited() -> void:
	is_hovered = false
	shown_mutation = null

	if tooltip_coordinator != null:
		tooltip_coordinator.clear_button_hover_mutation()


func _refresh_tooltip() -> void:
	var active_mutation: Mutation = (
		_get_active_mutation()
	)

	shown_mutation = active_mutation

	if tooltip_coordinator == null:
		return

	if active_mutation == null:
		tooltip_coordinator.clear_button_hover_mutation()
		return

	tooltip_coordinator.set_button_hover_mutation(
		active_mutation
	)


func _get_active_mutation() -> Mutation:
	if evolution_button_handler == null:
		return null

	return evolution_button_handler.active_mutation
