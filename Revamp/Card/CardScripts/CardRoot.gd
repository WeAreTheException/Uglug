extends Node2D
class_name CardRoot

signal hovered(card: CardRoot)
signal unhovered(card: CardRoot)

@export var test_data: CardData

@export var input: CardInput
@export var board_presence: BoardPresence
@export var stats: CardStats
@export var mutations: CardMutations
@export var card_visuals_root: CardVisualsRoot
@export var card_feedback: CardFeedback

@export var attack: Attack
@export var hurt: Hurt
@export var die: Die
@export var sacrifice: Sacrifice

@export var runtime_state: CardRuntimeState
@export var starts_as_revenant_for_debug: bool = false

var slots_root: SlotsRoot = null
var deck_system_root: DeckSystemRoot = null
var card_data: CardData = null
var card_name: String = ""
var runtime_id: String = ""


func _ready() -> void:
	_connect_input()
	setup_actions()

	if test_data != null:
		setup(test_data)


func setup(data: CardData) -> void:
	if data == null:
		return

	card_data = data
	card_name = data.name
	_ensure_runtime_id()

	if starts_as_revenant_for_debug or data.starts_as_revenant_for_debug:
		mark_revenant()
		print("REVENANT DEBUG: ", card_name, " is_revenant = ", is_revenant())

	if stats != null:
		stats.setup_from_data(data)

	if mutations != null:
		mutations.setup_from_data(data, self)

	if card_visuals_root != null:
		card_visuals_root.setup_from_card(self)


func setup_deck_system_context(new_deck_system_root: DeckSystemRoot) -> void:
	deck_system_root = new_deck_system_root


func get_runtime_id() -> String:
	_ensure_runtime_id()
	return runtime_id


func set_runtime_id(new_id: String) -> void:
	var clean_id := new_id.strip_edges()

	if clean_id == "":
		print("CardRoot blocked empty runtime ID on ", card_name)
		return

	runtime_id = clean_id


func can_receive_buff_mutation(mutation: Mutation) -> bool:
	if mutations == null:
		return false

	return mutations.can_add_buff_mutation(mutation)


func add_buff_mutation(mutation: Mutation) -> bool:
	if mutations == null:
		print("CardRoot buff blocked: mutations missing")
		return false

	return mutations.add_buff_mutation(mutation)


func setup_board_context(new_slots_root: SlotsRoot) -> void:
	slots_root = new_slots_root
	setup_actions()


func setup_actions() -> void:
	if attack != null:
		attack.setup(self, slots_root)

	if hurt != null:
		hurt.setup(self)

	if die != null:
		die.setup(self)

	if sacrifice != null:
		sacrifice.setup(self)


func set_hover_focused(value: bool) -> void:
	if card_feedback != null:
		card_feedback.set_hover_focused(value)


func set_drag_feedback(value: bool) -> void:
	if card_feedback != null:
		card_feedback.set_drag_feedback(value)


func set_prime_select_feedback(value: bool) -> void:
	if card_feedback != null:
		card_feedback.set_prime_select_feedback(value)


func clear_hand_feedback() -> void:
	set_hover_focused(false)
	set_drag_feedback(false)
	set_prime_select_feedback(false)


func start_sacrifice_anticipation() -> void:
	if sacrifice != null:
		sacrifice.start_anticipation()


func stop_sacrifice_anticipation() -> void:
	if sacrifice != null:
		sacrifice.stop_anticipation()


func set_sacrifice_selected(value: bool) -> void:
	if sacrifice != null:
		sacrifice.set_marked_for_sacrifice(value)


func set_pending_sacrifice(value: bool) -> void:
	if sacrifice != null:
		sacrifice.set_pending_sacrifice(value)


func play_committed_sacrifice() -> void:
	if sacrifice != null:
		sacrifice.play_committed_sacrifice()


func reset_sacrifice_feedback() -> void:
	if sacrifice != null:
		sacrifice.reset_sacrifice_state()


func get_sacrifice_worth() -> int:
	if stats != null:
		return stats.get_worth()

	if card_data != null:
		return card_data.worth

	return 1


func get_sacrifice_cost() -> int:
	if stats != null:
		return stats.get_cost()

	if card_data != null:
		return card_data.cost

	return 0


func is_on_board() -> bool:
	if board_presence == null:
		return false

	return board_presence.is_on_board()


func get_current_slot() -> Slot:
	if board_presence == null:
		return null

	return board_presence.current_slot


func set_revenant(value: bool) -> void:
	if runtime_state == null:
		print("REVENANT BLOCKED: runtime_state missing on ", card_name)
		return

	runtime_state.set_revenant(value)

	if card_visuals_root != null:
		card_visuals_root.refresh_revenant_visual()


func mark_revenant() -> void:
	set_revenant(true)


func clear_revenant() -> void:
	set_revenant(false)


func is_revenant() -> bool:
	if runtime_state == null:
		return false

	return runtime_state.has_revenant()


func _ensure_runtime_id() -> void:
	if runtime_id != "":
		return

	var base_id := "card"

	if card_data != null:
		base_id = card_data.get_safe_card_id()

	runtime_id = base_id + "_" + str(Time.get_ticks_usec()) + "_" + str(randi())


func _connect_input() -> void:
	if input == null:
		return

	if not input.hovered.is_connected(_on_input_hovered):
		input.hovered.connect(_on_input_hovered)

	if not input.unhovered.is_connected(_on_input_unhovered):
		input.unhovered.connect(_on_input_unhovered)


func _on_input_hovered() -> void:
	hovered.emit(self)


func _on_input_unhovered() -> void:
	unhovered.emit(self)
