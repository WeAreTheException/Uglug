extends Node
class_name EvolutionButtonHandler

@export var mutation_button: Button

@export var buff_flow_handler: BuffFlowHandler
@export var match_network_root: MatchNetworkRoot
@export var match_network_buff: MatchNetworkBuff
@export var deck_system_root: DeckSystemRoot

@export_group("Cursor")
@export_range(16, 256, 1)
var cursor_max_size: int = 96

@export var print_debug: bool = true

var active_mutation: Mutation = null
var is_active: bool = false
var is_targeting: bool = false
var request_pending: bool = false

var cursor_texture: Texture2D = null


func _ready() -> void:
	_connect_button()
	_connect_buff_flow()
	_connect_network_buff()

	call_deferred("_connect_hand_inputs")

	_set_button_visible(false)
	_restore_normal_cursor()


func _exit_tree() -> void:
	_restore_normal_cursor()


func _input(event: InputEvent) -> void:
	if not is_targeting:
		return

	if event is InputEventKey:
		var key_event := event as InputEventKey

		if (
			key_event.pressed
			and not key_event.echo
			and key_event.keycode == KEY_ESCAPE
		):
			_cancel_targeting()

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if (
			mouse_event.pressed
			and mouse_event.button_index
			== MOUSE_BUTTON_RIGHT
		):
			_cancel_targeting()


func _connect_button() -> void:
	if mutation_button == null:
		print(
			"EVOLUTION BLOCKED: mutation button missing"
		)
		return

	if not mutation_button.pressed.is_connected(
		_on_mutation_button_pressed
	):
		mutation_button.pressed.connect(
			_on_mutation_button_pressed
		)


func _connect_buff_flow() -> void:
	if buff_flow_handler == null:
		print(
			"EVOLUTION BLOCKED: BuffFlowHandler missing"
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
			"EVOLUTION BLOCKED: MatchNetworkBuff missing"
		)
		return

	if not match_network_buff.confirmed_buff_applied.is_connected(
		_on_confirmed_buff_applied
	):
		match_network_buff.confirmed_buff_applied.connect(
			_on_confirmed_buff_applied
		)


func _connect_hand_inputs() -> void:
	if deck_system_root == null:
		print(
			"EVOLUTION BLOCKED: DeckSystemRoot missing"
		)
		return

	_connect_hand(
		deck_system_root.player_one_hand
	)

	_connect_hand(
		deck_system_root.player_two_hand
	)


func _connect_hand(hand: PlayerHandRoot) -> void:
	if hand == null:
		return

	if hand.interaction_root == null:
		return

	if not hand.interaction_root.card_left_pressed.is_connected(
		_on_card_left_pressed
	):
		hand.interaction_root.card_left_pressed.connect(
			_on_card_left_pressed
		)


func _on_buff_started(
	_round_number: int
) -> void:
	is_active = true
	is_targeting = false
	request_pending = false
	active_mutation = null
	cursor_texture = null

	_restore_normal_cursor()
	_set_button_visible(false)

	if print_debug:
		print("EVOLUTION STARTED")


func _on_reward_generated(
	mutation: Mutation
) -> void:
	if mutation == null:
		return

	active_mutation = mutation
	request_pending = false
	is_targeting = false
	cursor_texture = null

	_restore_normal_cursor()
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
	is_targeting = false
	request_pending = false
	active_mutation = null
	cursor_texture = null

	_restore_normal_cursor()
	_set_button_visible(false)

	if print_debug:
		print("EVOLUTION FINISHED")


func _on_mutation_button_pressed() -> void:
	if not is_active:
		return

	if request_pending:
		return

	if active_mutation == null:
		return

	if is_targeting:
		_cancel_targeting()
		return

	_begin_targeting()


func _begin_targeting() -> void:
	if active_mutation == null:
		return

	if active_mutation.sigil_texture == null:
		print(
			"EVOLUTION CURSOR BLOCKED: sigil missing"
		)
		return

	cursor_texture = _build_cursor_texture(
		active_mutation.sigil_texture
	)

	if cursor_texture == null:
		print(
			"EVOLUTION CURSOR BLOCKED: "
			+ "cursor texture could not be created"
		)
		return

	is_targeting = true

	var hotspot := (
		cursor_texture.get_size() * 0.5
	)

	Input.set_custom_mouse_cursor(
		cursor_texture,
		Input.CURSOR_ARROW,
		hotspot
	)

	if mutation_button != null:
		mutation_button.disabled = true

	if print_debug:
		print(
			"EVOLUTION TARGETING STARTED: ",
			active_mutation.mutation_name
		)


func _build_cursor_texture(
	source_texture: Texture2D
) -> Texture2D:
	if source_texture == null:
		return null

	var image := source_texture.get_image()

	if image == null:
		return null

	if image.is_empty():
		return null

	var width := image.get_width()
	var height := image.get_height()

	if width <= 0 or height <= 0:
		return null

	var maximum_size := clampi(
		cursor_max_size,
		16,
		256
	)

	if (
		width > maximum_size
		or height > maximum_size
	):
		var scale_factor: float = minf(
			float(maximum_size) / float(width),
			float(maximum_size) / float(height)
		)

		var resized_width := maxi(
			int(round(width * scale_factor)),
			1
		)

		var resized_height := maxi(
			int(round(height * scale_factor)),
			1
		)

		image.resize(
			resized_width,
			resized_height,
			Image.INTERPOLATE_LANCZOS
		)

	return ImageTexture.create_from_image(image)


func _cancel_targeting() -> void:
	is_targeting = false
	cursor_texture = null

	_restore_normal_cursor()

	if mutation_button != null:
		mutation_button.disabled = (
			request_pending
			or not is_active
			or active_mutation == null
		)

	if print_debug:
		print("EVOLUTION TARGETING CANCELLED")


func _on_card_left_pressed(
	card: CardRoot
) -> void:
	if not is_targeting:
		return

	if request_pending:
		return

	if card == null:
		return

	if not is_instance_valid(card):
		return

	if active_mutation == null:
		return

	if not _card_belongs_to_local_hand(card):
		if print_debug:
			print(
				"EVOLUTION TARGET BLOCKED: "
				+ "not local hand"
			)
		return

	if not card.can_receive_buff_mutation(
		active_mutation
	):
		if print_debug:
			print(
				"EVOLUTION TARGET BLOCKED: "
				+ "card cannot receive mutation"
			)
		return

	_request_evolution(card)


func _request_evolution(
	card: CardRoot
) -> void:
	if match_network_root == null:
		print(
			"EVOLUTION REQUEST BLOCKED: "
			+ "MatchNetworkRoot missing"
		)
		return

	if active_mutation == null:
		print(
			"EVOLUTION REQUEST BLOCKED: "
			+ "active mutation missing"
		)
		return

	var requested_mutation := active_mutation
	var mutation_id := (
		requested_mutation.get_safe_mutation_id()
	)

	var mutation_name := (
		requested_mutation.mutation_name
	)

	var card_name := card.card_name
	var card_runtime_id := card.get_runtime_id()
	var owner := match_network_root.get_local_owner()

	request_pending = true
	is_targeting = false
	cursor_texture = null

	_restore_normal_cursor()
	_set_button_visible(false)

	match_network_root.request_buff_confirm(
		owner,
		card_runtime_id,
		mutation_id
	)

	# The network request can immediately finish Evolution
	# and clear active_mutation, so only use saved values here.
	if print_debug:
		print(
			"EVOLUTION REQUEST SENT: ",
			mutation_name,
			" -> ",
			card_name,
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

	if (
		owner
		!= match_network_root.get_local_owner()
	):
		return

	request_pending = true
	is_targeting = false
	cursor_texture = null

	_restore_normal_cursor()
	_set_button_visible(false)

	if print_debug:
		print(
			"EVOLUTION CONFIRMED: ",
			mutation.mutation_name,
			" -> ",
			card.card_name
		)


func _card_belongs_to_local_hand(
	card: CardRoot
) -> bool:
	if deck_system_root == null:
		return false

	var owner := SlotRow.SlotOwner.PLAYER

	if match_network_root != null:
		owner = match_network_root.get_local_owner()

	var hand := (
		deck_system_root.get_hand_for_owner(
			owner
		)
	)

	if hand == null:
		return false

	return hand.has_card(card)


func _update_button_visual() -> void:
	if mutation_button == null:
		return

	if active_mutation == null:
		return

	mutation_button.text = ""
	mutation_button.icon = (
		active_mutation.sigil_texture
	)

	mutation_button.expand_icon = true

	mutation_button.tooltip_text = (
		active_mutation.mutation_name
		+ "\n"
		+ active_mutation.mutation_description
	)


func _set_button_visible(
	value: bool
) -> void:
	if mutation_button == null:
		return

	mutation_button.visible = value

	mutation_button.disabled = (
		not value
		or request_pending
	)


func _restore_normal_cursor() -> void:
	Input.set_custom_mouse_cursor(
		null,
		Input.CURSOR_ARROW
	)
