extends Control
class_name MatchAnnouncementDisplay

@export var match_flow_root: MatchFlowRoot
@export var turn_order_state: MatchTurnOrderState

@export var round_label: Label
@export var message_label: Label

@export var hide_when_not_round_intro: bool = true

var current_round: int = 0


func _ready() -> void:
	visible = false

	if turn_order_state == null and match_flow_root != null:
		turn_order_state = match_flow_root.turn_order_state

	_connect_match_flow()
	_refresh_from_match_flow()


func _connect_match_flow() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.round_changed.is_connected(_on_round_changed):
		match_flow_root.round_changed.connect(_on_round_changed)

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _refresh_from_match_flow() -> void:
	if match_flow_root == null:
		return

	current_round = match_flow_root.current_round

	if match_flow_root.current_state == MatchFlowRoot.MatchState.ROUND_INTRO:
		_show_round_intro()
	elif hide_when_not_round_intro:
		visible = false


func _on_round_changed(round_number: int) -> void:
	current_round = round_number


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state == MatchFlowRoot.MatchState.ROUND_INTRO:
		_show_round_intro()
		return

	if hide_when_not_round_intro:
		visible = false


func _show_round_intro() -> void:
	visible = true

	if round_label != null:
		round_label.text = "Round %s" % current_round

	if message_label != null:
		message_label.text = _get_attacking_first_message()


func _get_attacking_first_message() -> String:
	if turn_order_state == null:
		return "Cards are attacking first"

	var owner_name := turn_order_state.get_owner_name(
		turn_order_state.attacking_first_owner
	)

	return "%s Attacks First" % owner_name
