extends Node
class_name BlessingFlowHandler

signal blessing_started
signal blessing_finished
signal blessing_applied(slot_owner: SlotRow.SlotOwner, card: CardRoot)

@export var match_flow_root: MatchFlowRoot
@export var selection_state: BlessingSelectionState
@export var blessing_to_apply: Blessing

@export var debug_p1_card: CardRoot
@export var debug_p2_card: CardRoot

@export var enable_debug_keys: bool = true
@export var auto_select_p1_key: Key = KEY_R
@export var auto_select_p2_key: Key = KEY_T
@export var finish_key: Key = KEY_Y

@export var print_debug: bool = true

var is_active: bool = false
var blessing_lookup: CardBlessingLookupHelper = CardBlessingLookupHelper.new()


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
		debug_select_card(SlotRow.SlotOwner.PLAYER)

	if key_event.keycode == auto_select_p2_key:
		debug_select_card(SlotRow.SlotOwner.OPPONENT)

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

	if card == null:
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

	_apply_blessing_to_owner(SlotRow.SlotOwner.PLAYER)
	_apply_blessing_to_owner(SlotRow.SlotOwner.OPPONENT)

	end_blessing()


func debug_select_card(slot_owner: SlotRow.SlotOwner) -> void:
	var card := _get_debug_card(slot_owner)

	if card == null:
		if print_debug:
			print(
				"BLESSING DEBUG BLOCKED: no debug card for ",
				_get_owner_name(slot_owner)
			)
		return

	select_card_for_owner(slot_owner, card)


func _apply_blessing_to_owner(slot_owner: SlotRow.SlotOwner) -> void:
	if blessing_to_apply == null:
		if print_debug:
			print("BLESSING APPLY BLOCKED: blessing_to_apply missing")
		return

	var card := selection_state.get_selected_card(slot_owner)

	if card == null:
		if print_debug:
			print(
				"BLESSING APPLY BLOCKED: no selected card for ",
				_get_owner_name(slot_owner)
			)
		return

	var card_blessings := blessing_lookup.get_card_blessings(card)

	if card_blessings == null:
		if print_debug:
			print(
				"BLESSING APPLY BLOCKED: CardBlessings missing on ",
				card.name
			)
		return

	card_blessings.add_blessing(blessing_to_apply)
	blessing_applied.emit(slot_owner, card)

	if print_debug:
		print(
			"BLESSING APPLIED: ",
			blessing_to_apply.get_display_name(),
			" -> ",
			_get_owner_name(slot_owner),
			" ",
			card.name
		)


func _get_debug_card(slot_owner: SlotRow.SlotOwner) -> CardRoot:
	match slot_owner:
		SlotRow.SlotOwner.PLAYER:
			return debug_p1_card

		SlotRow.SlotOwner.OPPONENT:
			return debug_p2_card

	return null


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
