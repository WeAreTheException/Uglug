extends Node
class_name BlessingCardSelectionHandler

@export var blessing_flow_handler: BlessingFlowHandler
@export var selection_state: BlessingSelectionState
@export var turn_order_state: MatchTurnOrderState

@export var player_one_hand: PlayerHandRoot
@export var player_two_hand: PlayerHandRoot

@export var instruction_label: CanvasItem
@export var instruction_text: String = "Choose a card to receive the blessing"

@export var print_debug: bool = true

var is_active: bool = false


func _ready() -> void:
	_connect_blessing_flow()
	_connect_hand(player_one_hand)
	_connect_hand(player_two_hand)
	_set_instruction_visible(false)


func _connect_blessing_flow() -> void:
	if blessing_flow_handler == null:
		return

	if not blessing_flow_handler.blessing_started.is_connected(_on_blessing_started):
		blessing_flow_handler.blessing_started.connect(_on_blessing_started)

	if not blessing_flow_handler.blessing_finished.is_connected(_on_blessing_finished):
		blessing_flow_handler.blessing_finished.connect(_on_blessing_finished)


func _connect_hand(hand: PlayerHandRoot) -> void:
	if hand == null:
		return

	if hand.interaction_root == null:
		return

	if not hand.interaction_root.card_left_pressed.is_connected(_on_card_pressed):
		hand.interaction_root.card_left_pressed.connect(_on_card_pressed)


func _on_blessing_started() -> void:
	is_active = true

	_set_instruction_visible(true)

	if print_debug:
		print("BLESSING CARD SELECTION STARTED")


func _on_blessing_finished() -> void:
	is_active = false

	_set_instruction_visible(false)

	if print_debug:
		print("BLESSING CARD SELECTION FINISHED")


func _on_card_pressed(card: CardRoot) -> void:
	if not is_active:
		return

	if card == null:
		return

	var owner := _get_owner_for_card(card)

	if not _is_controlled_owner(owner):
		if print_debug:
			print("Blessing selection blocked: not controlled owner")
		return

	if selection_state == null:
		return

	selection_state.select_card(owner, card)

	if print_debug:
		print("BLESSING SELECTED: ", _get_owner_name(owner), " -> ", card.card_name)


func _set_instruction_visible(value: bool) -> void:
	if instruction_label == null:
		return

	instruction_label.visible = value

	if value:
		if instruction_label is Label:
			(instruction_label as Label).text = instruction_text

		if instruction_label is RichTextLabel:
			(instruction_label as RichTextLabel).text = instruction_text


func _get_owner_for_card(card: CardRoot) -> SlotRow.SlotOwner:
	if player_one_hand != null and player_one_hand.has_card(card):
		return SlotRow.SlotOwner.PLAYER

	return SlotRow.SlotOwner.OPPONENT


func _is_controlled_owner(owner: SlotRow.SlotOwner) -> bool:
	if turn_order_state == null:
		return true

	return turn_order_state.controlled_owner == owner


func _get_owner_name(owner: SlotRow.SlotOwner) -> String:
	match owner:
		SlotRow.SlotOwner.PLAYER:
			return "P1"
		SlotRow.SlotOwner.OPPONENT:
			return "P2"

	return "UNKNOWN"
