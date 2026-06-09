extends Node2D
class_name CardRoot

signal hovered(card: CardRoot)
signal unhovered(card: CardRoot)
signal placed(card: CardRoot, slot: Slot)
signal left_board(card: CardRoot)
signal attack_started(context: AttackContext)
signal attack_hit(context: AttackContext)
signal attack_finished(context: AttackContext)
signal damaged(context: DamageContext)
signal died(context: DeathContext)

@export var test_data: CardData
@export var visuals_root: CardVisualsRoot
@export var functionality_root: CardFunctionalityRoot
@export var feedback_root: CardFeedbackRoot

var slots_root: SlotsRoot = null
var card_data: CardData = null
var card_name: String = ""

func _ready() -> void:
	_setup_roots()
	if test_data != null:
		setup(test_data)

func setup(data: CardData) -> void:
	if data == null:
		return
	card_data = data
	card_name = data.name
	if functionality_root != null:
		functionality_root.setup_from_card(self)
		functionality_root.setup_from_data(data)
	if visuals_root != null:
		visuals_root.setup_from_card(self)
	if feedback_root != null:
		feedback_root.setup_from_card(self)

func setup_board_context(new_slots_root: SlotsRoot) -> void:
	slots_root = new_slots_root
	if functionality_root != null:
		functionality_root.setup_board_context(new_slots_root)

func enter_slot(slot: Slot) -> bool:
	if functionality_root == null:
		return false
	var success := functionality_root.enter_slot(slot)
	if success:
		placed.emit(self, slot)
		if feedback_root != null:
			feedback_root.play_placed()
	return success

func leave_slot(reason: String = CardLeaveReason.NONE) -> void:
	if functionality_root != null:
		functionality_root.leave_slot(reason)
	left_board.emit(self)

func perform_attack() -> void:
	if functionality_root != null:
		await functionality_root.perform_attack()

func receive_damage(context: DamageContext) -> int:
	if functionality_root == null:
		return 0
	var amount: int = await functionality_root.receive_damage(context)
	if context != null and amount > 0:
		damaged.emit(context)
	return amount

func die(context: DeathContext = null) -> void:
	if functionality_root != null:
		await functionality_root.die(context)
	if context != null:
		died.emit(context)

func is_on_board() -> bool:
	return functionality_root != null and functionality_root.is_on_board()

func get_current_slot() -> Slot:
	return null if functionality_root == null else functionality_root.get_current_slot()

func get_sacrifice_worth() -> int:
	return 1 if functionality_root == null else functionality_root.get_worth()

func get_sacrifice_cost() -> int:
	return 0 if functionality_root == null else functionality_root.get_cost()

func _setup_roots() -> void:
	if functionality_root != null:
		functionality_root.setup_from_card(self)
	if visuals_root != null:
		visuals_root.setup_from_card(self)
	if feedback_root != null:
		feedback_root.setup_from_card(self)
