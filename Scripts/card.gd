extends Node2D
class_name Card

enum Owner {
	PLAYER,
	OPPONENT
}

@export var input_listener: CardInputListener
@export var drag_handler: DragHandler
@export var stats: Stats
@export var test_data: CardData

var card_owner: Owner = Owner.PLAYER

var player_hand: Node2D = null
var current_slot: NewSlots = null
var overlapping_slot: NewSlots = null
var hand_position: Vector2

var card_name: String = ""

var current_attack: int = 0
var current_health: int = 0
var current_cost: int = 0

func _ready() -> void:
	if input_listener != null:
		input_listener.slot_entered.connect(_on_slot_entered)
		input_listener.slot_exited.connect(_on_slot_exited)

	if test_data != null:
		setup_card(test_data)

func setup_card(data: CardData) -> void:
	if data == null:
		print("FAIL: setup_card got null data")
		return

	card_name = data.name
	current_attack = data.attack
	current_health = data.health
	current_cost = data.cost

	print("CARD setup_card called with: ", data.name)

	if stats != null:
		stats.setup_from_card_data(data)
	else:
		print("FAIL: stats is null on card")

func take_damage(amount: int) -> void:
	current_health -= amount

	if current_health < 0:
		current_health = 0

	print(card_name, " took damage. Current health: ", current_health)

	if stats != null:
		stats.update_health(current_health)

func kill() -> void:
	current_health = 0
	print(card_name, " died. Current health: ", current_health)

	if stats != null:
		stats.update_health(current_health)

func _on_slot_entered(slot: NewSlots) -> void:
	overlapping_slot = slot

func _on_slot_exited(slot: NewSlots) -> void:
	if overlapping_slot == slot:
		overlapping_slot = null

func place_into_slot(slot: NewSlots) -> void:
	if slot == null:
		return_to_hand()
		return

	if slot.current_card != null and slot.current_card != self:
		var old_card = slot.current_card
		slot.clear_card()
		old_card.current_slot = null

		if old_card.player_hand != null:
			old_card.player_hand.add_card_to_hand(old_card)

	slot.assign_card(self)
	current_slot = slot
	global_position = slot.global_position

func return_to_hand() -> void:
	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	if player_hand != null:
		player_hand.add_card_to_hand(self)
