extends Node
class_name BlessingFlowHandler

signal blessing_started
signal blessing_finished

@export var match_flow_root: MatchFlowRoot
@export var selection_state: BlessingSelectionState

@export var enable_debug_keys: bool = true
@export var auto_select_p1_key: Key = KEY_R
@export var auto_select_p2_key: Key = KEY_T
@export var finish_key: Key = KEY_Y

@export var print_debug: bool = true

var is_active: bool = false


func _ready() -> void:
	if match_flow_root == null:
		return

	if not match_flow_root.match_state_changed.is_connected(_on_match_state_changed):
		match_flow_root.match_state_changed.connect(_on_match_state_changed)


func _input(event: InputEvent) -> void:
	if not enable_debug_keys:
		return

	if not is_active:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == auto_select_p1_key:
		debug_select_placeholder_card(SlotRow.SlotOwner.PLAYER)

	if key_event.keycode == auto_select_p2_key:
		debug_select_placeholder_card(SlotRow.SlotOwner.OPPONENT)

	if key_event.keycode == finish_key:
		try_finish_blessing()


func begin_blessing() -> void:
	is_active = true

	if selection_state != null:
		selection_state.clear_selections()

	if print_debug:
		print("BLESSING STARTED")

	blessing_started.emit()


func end_blessing() -> void:
	if not is_active:
		return

	is_active = false

	if print_debug:
		print("BLESSING FINISHED")

	blessing_finished.emit()


func select_card_for_owner(
	slot_owner: SlotRow.SlotOwner,
	card: CardRoot
) -> void:
	if not is_active:
		return

	if selection_state == null:
		return

	selection_state.select_card(slot_owner, card)

	if print_debug:
		print(
			"BLESSING SELECTED: ",
			_get_owner_name(slot_owner),
			" -> ",
			card.name
		)


func try_finish_blessing() -> void:
	if selection_state == null:
		return

	if not selection_state.has_all_selections():
		if print_debug:
			print("BLESSING BLOCKED: missing selection")
		return

	end_blessing()


func debug_select_placeholder_card(slot_owner: SlotRow.SlotOwner) -> void:
	if selection_state == null:
		return

	var fake_card := CardRoot.new()
	fake_card.name = "DebugBlessingCard"

	selection_state.select_card(slot_owner, fake_card)

	if print_debug:
		print(
			"BLESSING DEBUG SELECTED: ",
			_get_owner_name(slot_owner)
		)


func _on_match_state_changed(state: MatchFlowRoot.MatchState) -> void:
	if state == MatchFlowRoot.MatchState.BLESSING:
		begin_blessing()
		return

	if is_active:
		end_blessing()


func _get_owner_name(slot_owner: SlotRow.SlotOwner) -> String:
	match slot_owner:
		SlotRow.SlotOwner.PLAYER:
			return "P1"

		SlotRow.SlotOwner.OPPONENT:
			return "P2"

	return "UNKNOWN"
