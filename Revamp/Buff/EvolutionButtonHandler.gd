extends Node
class_name EvolutionButtonHandler

@export var mutation_button: Button

@export var buff_flow_handler: BuffFlowHandler
@export var match_network_root: MatchNetworkRoot
@export var match_network_buff: MatchNetworkBuff
@export var deck_system_root: DeckSystemRoot

@export var print_debug: bool = true

var active_mutation: Mutation = null
var is_active: bool = false
var is_dragging: bool = false
var request_sent: bool = false

var original_global_position: Vector2
var drag_offset: Vector2
var original_mouse_filter: Control.MouseFilter


func _ready() -> void:
	if mutation_button != null:
		original_global_position = (
			mutation_button.global_position
		)

		original_mouse_filter = (
			mutation_button.mouse_filter
		)

		if not mutation_button.button_down.is_connected(
			_on_button_down
		):
			mutation_button.button_down.connect(
				_on_button_down
			)

		mutation_button.visible = false
		mutation_button.disabled = true

	_connect_buff_flow()
	_connect_network_buff()


func _process(_delta: float) -> void:
	if not is_dragging:
		return

	if mutation_button == null:
		return

	mutation_button.global_position = (
		mutation_button.get_global_mouse_position()
		- drag_offset
	)


func _input(event: InputEvent) -> void:
	if not is_dragging:
		return

	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton

	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return

	if mouse_event.pressed:
		return

	_finish_drag()


func _connect_buff_flow() -> void:
	if buff_flow_handler == null:
		print(
			"EVOLUTION BUTTON BLOCKED: "
			+ "BuffFlowHandler missing"
		)
		return

	if not buff_flow_handler.buff_started.is_connected(
		_on_buff_started
	):
		buff_flow_handler.buff_started.connect(
			_on_buff_started
		)

	if not buff_flow_handler.reward_generated.is_connected(
		_on_reward_generated
	):
		buff_flow_handler.reward_generated.connect(
			_on_reward_generated
		)

	if not buff_flow_handler.buff_finished.is_connected(
		_on_buff_finished
	):
		buff_flow_handler.buff_finished.connect(
			_on_buff_finished
		)


func _connect_network_buff() -> void:
	if match_network_buff == null:
		print(
			"EVOLUTION BUTTON BLOCKED: "
			+ "MatchNetworkBuff missing"
		)
		return

	if not match_network_buff.confirmed_buff_applied.is_connected(
		_on_confirmed_buff_applied
	):
		match_network_buff.confirmed_buff_applied.connect(
			_on_confirmed_buff_applied
		)


func _on_buff_started(
	_round_number: int
) -> void:
	is_active = true
	is_dragging = false
	request_sent = false
	active_mutation = null

	_restore_button_position()
	_set_button_visible(false)

	if print_debug:
		print("EVOLUTION BUTTON STARTED")


func _on_reward_generated(
	mutation: Mutation
) -> void:
	if mutation == null:
		return

	active_mutation = mutation
	request_sent = false

	_update_button_visual()
	_set_button_visible(true)

	if print_debug:
		print(
			"EVOLUTION MUTATION READY: ",
			mutation.mutation_name
		)


func _on_buff_finished(
	_round_number: int
) -> void:
	is_active = false
	is_dragging = false
	request_sent = false
	active_mutation = null

	if mutation_button != null:
		mutation_button.mouse_filter = (
			original_mouse_filter
		)

	_restore_button_position()
	_set_button_visible(false)

	if print_debug:
		print("EVOLUTION BUTTON FINISHED")


func _on_button_down() -> void:
	if not is_active:
		return

	if request_sent:
		return

	if active_mutation == null:
		return

	if mutation_button == null:
		return

	is_dragging = true

	drag_offset = (
		mutation_button.get_global_mouse_position()
		- mutation_button.global_position
	)

	mutation_button.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	mutation_button.move_to_front()

	if print_debug:
		print("EVOLUTION DRAG STARTED")


func _finish_drag() -> void:
	is_dragging = false

	if mutation_button != null:
		mutation_button.mouse_filter = (
			original_mouse_filter
		)

	var target_card := _get_hovered_local_card()

	if target_card == null:
		_restore_button_position()

		if print_debug:
			print(
				"EVOLUTION DROP FAILED: "
				+ "no hovered local card"
			)

		return

	if active_mutation == null:
		_restore_button_position()
		return

	if not target_card.can_receive_buff_mutation(
		active_mutation
	):
		_restore_button_position()

		if print_debug:
			print(
				"EVOLUTION DROP FAILED: "
				+ "card cannot receive mutation"
			)

		return

	_request_apply(target_card)


func _request_apply(card: CardRoot) -> void:
	if match_network_root == null:
		print(
			"EVOLUTION APPLY BLOCKED: "
			+ "MatchNetworkRoot missing"
		)

		_restore_button_position()
		return

	request_sent = true
	_restore_button_position()
	_set_button_visible(false)

	var owner := match_network_root.get_local_owner()

	match_network_root.request_buff_confirm(
		owner,
		card.get_runtime_id(),
		active_mutation.get_safe_mutation_id()
	)

	if print_debug:
		print(
			"EVOLUTION REQUEST SENT: ",
			active_mutation.mutation_name,
			" -> ",
			card.card_name,
			" | OWNER: ",
			owner
		)


func _on_confirmed_buff_applied(
	owner: SlotRow.SlotOwner,
	card: CardRoot,
	mutation: Mutation
) -> void:
	if match_network_root == null:
		return

	if owner != match_network_root.get_local_owner():
		return

	request_sent = true
	_set_button_visible(false)

	if print_debug:
		print(
			"EVOLUTION CONFIRMED: ",
			mutation.mutation_name,
			" -> ",
			card.card_name
		)


func _get_hovered_local_card() -> CardRoot:
	if deck_system_root == null:
		return null

	var owner := _get_local_owner()

	var hand := deck_system_root.get_hand_for_owner(
		owner
	)

	if hand == null:
		return null

	if hand.interaction_root == null:
		return null

	if hand.interaction_root.hover_focus == null:
		return null

	var card := (
		hand.interaction_root
		.hover_focus
		.focused_card
	)

	if card == null:
		return null

	if not is_instance_valid(card):
		return null

	if not hand.has_card(card):
		return null

	return card


func _get_local_owner() -> SlotRow.SlotOwner:
	if match_network_root != null:
		return match_network_root.get_local_owner()

	return SlotRow.SlotOwner.PLAYER


func _update_button_visual() -> void:
	if mutation_button == null:
		return

	if active_mutation == null:
		return

	mutation_button.text = ""
	mutation_button.icon = active_mutation.sigil_texture
	mutation_button.expand_icon = true

	mutation_button.tooltip_text = (
		active_mutation.mutation_name
		+ "\n"
		+ active_mutation.mutation_description
	)


func _set_button_visible(value: bool) -> void:
	if mutation_button == null:
		return

	mutation_button.visible = value
	mutation_button.disabled = not value


func _restore_button_position() -> void:
	if mutation_button == null:
		return

	mutation_button.global_position = (
		original_global_position
	)
