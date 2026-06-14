extends Node
class_name BlessingApplyHandler

signal blessing_applied(card: CardRoot, blessing: Blessing)

@export var blessing_flow_handler: BlessingFlowHandler
@export var selection_state: BlessingSelectionState
@export var turn_order_state: MatchTurnOrderState

@export var enable_debug_confirm_key: bool = true
@export var debug_confirm_key: Key = KEY_ENTER
@export var print_debug: bool = true

var is_active: bool = false
var has_confirmed: bool = false


func _ready() -> void:
	if blessing_flow_handler == null:
		return

	if not blessing_flow_handler.blessing_started.is_connected(_on_blessing_started):
		blessing_flow_handler.blessing_started.connect(_on_blessing_started)

	if not blessing_flow_handler.blessing_finished.is_connected(_on_blessing_finished):
		blessing_flow_handler.blessing_finished.connect(_on_blessing_finished)


func _input(event: InputEvent) -> void:
	if not enable_debug_confirm_key:
		return

	if not is_active:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == debug_confirm_key:
		confirm_blessing()


func confirm_blessing() -> bool:
	if not is_active:
		return false

	if has_confirmed:
		print("Blessing confirm blocked: already confirmed")
		return false

	if blessing_flow_handler == null or selection_state == null:
		return false

	var blessing := blessing_flow_handler.get_active_blessing()

	if blessing == null:
		print("Blessing confirm blocked: no active blessing")
		return false

	var owner := _get_controlled_owner()
	var card := selection_state.get_selected_card(owner)

	if card == null:
		print("Blessing confirm blocked: no selected card")
		return false

	has_confirmed = true

	_apply_blessing(card, blessing)
	blessing_applied.emit(card, blessing)

	if print_debug:
		print("BLESSING APPLIED: ", blessing.get_display_name(), " -> ", card.card_name)

	_finish_after_apply()
	return true


func _apply_blessing(card: CardRoot, blessing: Blessing) -> void:
	if _is_revenant_blessing(blessing):
		card.mark_revenant()
		return

	var card_blessings := CardBlessingLookupHelper.new().get_card_blessings(card)

	if card_blessings == null:
		print("Blessing apply blocked: CardBlessings missing on ", card.card_name)
		return

	card_blessings.add_blessing(blessing)


func _finish_after_apply() -> void:
	if selection_state != null:
		selection_state.clear_selections()

	if blessing_flow_handler != null:
		blessing_flow_handler.finish_blessing_flow()


func _on_blessing_started() -> void:
	is_active = true
	has_confirmed = false


func _on_blessing_finished() -> void:
	is_active = false
	has_confirmed = false


func _get_controlled_owner() -> SlotRow.SlotOwner:
	if turn_order_state == null:
		return SlotRow.SlotOwner.PLAYER

	return turn_order_state.controlled_owner


func _is_revenant_blessing(blessing: Blessing) -> bool:
	if blessing == null:
		return false

	if blessing is RevenantBlessing:
		return true

	return blessing.blessing_id == "revenant"
