extends Node
class_name CardFunctionalityRoot

@export var input: CardInput
@export var state: CardState
@export var board_presence: BoardPresence
@export var stats: CardStats
@export var mutations: CardMutations
@export var attack: Attack
@export var hurt: Hurt
@export var die_action: Die
@export var sacrifice: Sacrifice

var card: CardRoot = null
var slots_root: SlotsRoot = null

func setup_from_card(source_card: CardRoot) -> void:
	card = source_card
	_setup_children()

func setup_from_data(data: CardData) -> void:
	if state != null:
		state.setup_from_data(data)
	if stats != null:
		stats.setup_from_data(data)
	if mutations != null:
		mutations.setup_from_data(data, card)

func setup_board_context(new_slots_root: SlotsRoot) -> void:
	slots_root = new_slots_root
	_setup_children()

func enter_slot(slot: Slot) -> bool:
	return false if board_presence == null else board_presence.enter_slot(slot)

func leave_slot(reason: String) -> void:
	if board_presence != null:
		board_presence.leave_slot(reason)

func perform_attack() -> void:
	if attack != null:
		await attack.perform_attack()

func receive_damage(context: DamageContext) -> int:
	return 0 if hurt == null else await hurt.receive_damage(context)

func die(context: DeathContext = null) -> void:
	if die_action != null:
		await die_action.play_die(context)

func is_on_board() -> bool:
	return board_presence != null and board_presence.is_on_board()

func get_current_slot() -> Slot:
	return null if board_presence == null else board_presence.current_slot

func get_worth() -> int:
	return 1 if stats == null else stats.get_worth()

func get_cost() -> int:
	return 0 if stats == null else stats.get_cost()

func _setup_children() -> void:
	if input != null:
		input.setup(card)
	if state != null:
		state.setup(card)
	if board_presence != null:
		board_presence.setup(card)
	if attack != null:
		attack.setup(card, slots_root)
	if hurt != null:
		hurt.setup(card)
	if die_action != null:
		die_action.setup(card)
	if sacrifice != null:
		sacrifice.setup(card)
