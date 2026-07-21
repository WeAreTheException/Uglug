extends Node
class_name MutationButtonHoverBinder

@export var match_ui: MatchUiRoot
@export var mutation_button: Button
@export var mutation_tooltip: MutationToolTip

var is_hovered: bool = false
var shown_mutation: Mutation = null


func _ready() -> void:
	_connect_button()


func _process(_delta: float) -> void:
	if not is_hovered:
		return

	var active_mutation: Mutation = _get_active_mutation()

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

	if mutation_tooltip != null:
		mutation_tooltip.show_default_tooltip()


func _refresh_tooltip() -> void:
	var active_mutation: Mutation = _get_active_mutation()
	shown_mutation = active_mutation

	if mutation_tooltip == null:
		return

	if active_mutation == null:
		mutation_tooltip.show_default_tooltip()
		return

	mutation_tooltip.show_mutation(active_mutation)


func _get_active_mutation() -> Mutation:
	if match_ui == null:
		return null

	return match_ui.get_active_mutation()
