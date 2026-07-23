extends Node
class_name PlayHandUiBinder


@export_group("UI")
@export var match_ui: MatchPhaseUI
@export var match_flow_root: MatchFlowRoot

@export_group("Hands")
@export var player_hand: PlayerHandRoot
@export var player_one_hand: PlayerHandRoot
@export var player_two_hand: PlayerHandRoot

@export_group("Placement")
@export var sacrifice_controller: SacrificeController

@export_group("Text Colors")
@export var active_color: Color = Color.WHITE

@export var completed_color: Color = Color(
	1.0,
	1.0,
	1.0,
	0.35
)

@export var future_color: Color = Color(
	1.0,
	1.0,
	1.0,
	0.55
)

@export var number_color: Color = Color(
	1.0,
	0.9,
	0.15,
	1.0
)

@export_group("Font Sizes")
@export var active_font_size: int = 18
@export var normal_font_size: int = 16

@export_group("Text")
@export var select_card_text: String = "Select Card"

@export var choose_martyrs_text: String = (
	"Choose %s martyr%s"
)

@export var place_text: String = "Place"

@export_group("Debug")
@export var print_debug: bool = false


func _ready() -> void:
	_connect_match_ui()

	_connect_hand(player_hand)
	_connect_hand(player_one_hand)
	_connect_hand(player_two_hand)

	_connect_sacrifice_controller()

	call_deferred("refresh")


func refresh() -> void:
	if match_ui == null:
		return

	if match_ui.description_label == null:
		return

	if (
		match_ui.current_phase
		!= MatchPhaseUI.Phase.PLAY
	):
		return

	var primed_card: CardRoot = _get_primed_card()

	if primed_card == null:
		_set_helper_text(
			_active_line(select_card_text)
			+ "\n"
			+ _future_line(
				"Choose x martyrs"
			)
			+ "\n"
			+ _future_line(place_text)
		)

		return

	var required_worth: int = (
		primed_card.get_sacrifice_cost()
	)

	var selected_worth: int = (
		_get_current_martyr_worth()
	)

	var remaining: int = maxi(
		required_worth - selected_worth,
		0
	)

	var martyr_plural: String = (
		""
		if remaining == 1
		else "s"
	)

	var selected_line: String = (
		"Selected %s"
		% primed_card.card_name
	)

	var martyr_line: String = _martyr_line(
		remaining,
		martyr_plural,
		remaining > 0
	)

	_print(
		(
			"UI REFRESH | "
			+ "card=%s "
			+ "required=%s "
			+ "selected=%s "
			+ "remaining=%s "
			+ "pending=%s"
		)
		% [
			primed_card.card_name,
			required_worth,
			selected_worth,
			remaining,
			str(_has_pending_sacrifices())
		]
	)

	if remaining > 0:
		_set_helper_text(
			_completed_line(selected_line)
			+ "\n"
			+ martyr_line
			+ "\n"
			+ _future_line(place_text)
		)

		return

	_set_helper_text(
		_completed_line(selected_line)
		+ "\n"
		+ martyr_line
		+ "\n"
		+ _active_line(place_text)
	)


func _connect_match_ui() -> void:
	if match_ui == null:
		return

	if not match_ui.phase_changed.is_connected(
		_on_phase_changed
	):
		match_ui.phase_changed.connect(
			_on_phase_changed
		)


func _connect_hand(hand: PlayerHandRoot) -> void:
	if hand == null:
		return

	if not hand.card_primed.is_connected(
		_on_card_primed
	):
		hand.card_primed.connect(
			_on_card_primed
		)

	if not hand.card_unprimed.is_connected(
		_on_card_unprimed
	):
		hand.card_unprimed.connect(
			_on_card_unprimed
		)

	if not hand.sacrifice_selection_changed.is_connected(
		_on_hand_sacrifice_selection_changed
	):
		hand.sacrifice_selection_changed.connect(
			_on_hand_sacrifice_selection_changed
		)


func _connect_sacrifice_controller() -> void:
	if sacrifice_controller == null:
		return

	if not sacrifice_controller.sacrifice_requirement_changed.is_connected(
		_on_sacrifice_requirement_changed
	):
		sacrifice_controller.sacrifice_requirement_changed.connect(
			_on_sacrifice_requirement_changed
		)

	if not sacrifice_controller.pending_sacrifice_started.is_connected(
		_on_pending_sacrifice_started
	):
		sacrifice_controller.pending_sacrifice_started.connect(
			_on_pending_sacrifice_started
		)

	if not sacrifice_controller.pending_sacrifice_undone.is_connected(
		_on_pending_sacrifice_undone
	):
		sacrifice_controller.pending_sacrifice_undone.connect(
			_on_pending_sacrifice_undone
		)

	if not sacrifice_controller.sacrifice_committed.is_connected(
		_on_sacrifice_committed
	):
		sacrifice_controller.sacrifice_committed.connect(
			_on_sacrifice_committed
		)


func _on_phase_changed(
	new_phase: MatchPhaseUI.Phase
) -> void:
	if new_phase != MatchPhaseUI.Phase.PLAY:
		return

	refresh()


func _on_card_primed(_card: CardRoot) -> void:
	refresh()


func _on_card_unprimed(_card: CardRoot) -> void:
	refresh()


func _on_hand_sacrifice_selection_changed(
	_cards: Array[CardRoot]
) -> void:
	refresh()


func _on_sacrifice_requirement_changed(
	_current_worth: int,
	_required_worth: int
) -> void:
	refresh()


func _on_pending_sacrifice_started(
	_primed_card: CardRoot,
	_cards: Array[CardRoot]
) -> void:
	refresh()


func _on_pending_sacrifice_undone(
	_primed_card: CardRoot,
	_cards: Array[CardRoot]
) -> void:
	refresh()


func _on_sacrifice_committed(
	_cards: Array[CardRoot]
) -> void:
	refresh()


func _get_local_player_hand() -> PlayerHandRoot:
	if (
		match_flow_root == null
		or match_flow_root.turn_order_state == null
	):
		return player_hand

	var controlled_owner: SlotRow.SlotOwner = (
		match_flow_root
			.turn_order_state
			.controlled_owner
	)

	if controlled_owner == SlotRow.SlotOwner.PLAYER:
		if player_one_hand != null:
			return player_one_hand

	if controlled_owner == SlotRow.SlotOwner.OPPONENT:
		if player_two_hand != null:
			return player_two_hand

	return player_hand


func _get_primed_card() -> CardRoot:
	var local_hand: PlayerHandRoot = (
		_get_local_player_hand()
	)

	if local_hand == null:
		return null

	return local_hand.get_primed_card()


func _get_current_martyr_worth() -> int:
	var pending_cards: Array[CardRoot] = (
		_get_pending_sacrifice_cards()
	)

	if not pending_cards.is_empty():
		return _get_cards_worth(
			pending_cards
		)

	var local_hand: PlayerHandRoot = (
		_get_local_player_hand()
	)

	if local_hand == null:
		return 0

	return _get_cards_worth(
		local_hand.get_selected_sacrifice_cards()
	)


func _get_pending_sacrifice_cards() -> Array[CardRoot]:
	if sacrifice_controller == null:
		return []

	return (
		sacrifice_controller
			.get_pending_sacrifice_cards()
	)


func _has_pending_sacrifices() -> bool:
	return not (
		_get_pending_sacrifice_cards()
			.is_empty()
	)


func _get_cards_worth(
	cards: Array[CardRoot]
) -> int:
	var total: int = 0

	for card: CardRoot in cards:
		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		total += card.get_sacrifice_worth()

	return total


func _set_helper_text(text: String) -> void:
	if match_ui == null:
		return

	if match_ui.description_label == null:
		return

	match_ui.description_label.bbcode_enabled = true
	match_ui.description_label.text = text


func _martyr_line(
	remaining: int,
	martyr_plural: String,
	is_active: bool
) -> String:
	var line_color: Color = (
		active_color
		if is_active
		else completed_color
	)

	var font_size: int = (
		active_font_size
		if is_active
		else normal_font_size
	)

	var faded_number_color: Color = number_color
	faded_number_color.a = line_color.a

	return (
		"[font_size=%s]"
		+ "[color=%s]Choose [/color]"
		+ "[color=%s]%s[/color]"
		+ "[color=%s] martyr%s[/color]"
		+ "[/font_size]"
	) % [
		font_size,
		line_color.to_html(),
		faded_number_color.to_html(),
		remaining,
		line_color.to_html(),
		martyr_plural
	]


func _active_line(text: String) -> String:
	return (
		"[font_size=%s]"
		+ "[color=%s]%s[/color]"
		+ "[/font_size]"
	) % [
		active_font_size,
		active_color.to_html(),
		text
	]


func _completed_line(text: String) -> String:
	return (
		"[font_size=%s]"
		+ "[color=%s]%s[/color]"
		+ "[/font_size]"
	) % [
		normal_font_size,
		completed_color.to_html(),
		text
	]


func _future_line(text: String) -> String:
	return (
		"[font_size=%s]"
		+ "[color=%s]%s[/color]"
		+ "[/font_size]"
	) % [
		normal_font_size,
		future_color.to_html(),
		text
	]


func _print(message: String) -> void:
	if print_debug:
		print(message)
