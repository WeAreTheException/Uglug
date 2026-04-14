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
@export var battle_scale: BattleScale

var card_owner: Owner = Owner.PLAYER

var player_hand: Node2D = null
var current_slot: NewSlots = null
var overlapping_slot: NewSlots = null
var hand_position: Vector2

var card_name: String = ""
var is_hovered: bool = false
var is_selected: bool = false

var current_attack: int = 0
var current_health: int = 0
var current_cost: int = 0

var move_tween: Tween = null
var scale_tween: Tween = null

func _ready() -> void:
	if input_listener != null:
		input_listener.hovered.connect(_on_hovered)
		input_listener.hovered_off.connect(_on_hovered_off)
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

	print("setup: ", data.name)

	if stats != null:
		stats.setup_from_card_data(data)
	else:
		print("FAIL: stats is null on card")

func take_damage(amount: int) -> void:
	current_health -= amount

	if current_health < 0:
		current_health = 0

	if current_health <= 0:
		if stats != null:
			stats.update_health(current_health)

		kill()
		return

	if stats != null:
		stats.update_health(current_health)

	print(card_name, " (", current_health, " hp)")

func kill() -> void:
	current_health = 0

	if stats != null:
		stats.update_health(current_health)

	print(card_name, " died")

	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	queue_free()

func _on_hovered(_listener) -> void:
	is_hovered = true

func _on_hovered_off(_listener) -> void:
	is_hovered = false

func _on_slot_entered(slot: NewSlots) -> void:
	overlapping_slot = slot

func _on_slot_exited(slot: NewSlots) -> void:
	if overlapping_slot == slot:
		overlapping_slot = null

func set_selected(value: bool) -> void:
	is_selected = value

	if scale_tween != null:
		scale_tween.kill()

	scale_tween = create_tween()

	if is_selected:
		scale_tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.12)
	else:
		scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12)

func place_into_slot(slot: NewSlots) -> void:
	if slot == null:
		print("place_into_slot failed: slot null")
		return

	print("place_into_slot called for ", card_name, " -> ", slot.name)

	if not slot.assign_card(self):
		print("place_into_slot failed: assign_card returned false")
		return

	if current_slot != null and current_slot != slot:
		current_slot.clear_card()

	current_slot = slot

	if player_hand != null:
		player_hand.remove_card_from_hand(self)

	animate_to_position(slot.global_position)

	apply_slot_owner(slot)
	print_slot_info()

	if player_hand != null:
		player_hand.remove_card_from_hand(self)

	animate_to_position(slot.global_position)

	apply_slot_owner(slot)
	print_slot_info()

func animate_to_position(target_pos: Vector2) -> void:
	if move_tween != null:
		move_tween.kill()

	move_tween = create_tween()
	move_tween.tween_property(self, "global_position", target_pos, 0.18)

func apply_slot_owner(slot: NewSlots) -> void:
	if slot == null:
		return

	if slot.slot_owner == NewSlots.SlotOwner.PLAYER:
		card_owner = Owner.PLAYER
	else:
		card_owner = Owner.OPPONENT

func print_slot_info() -> void:
	if current_slot == null:
		print(card_name, " has no slot")
		return

	var slot_side := ""
	var card_side := ""

	if current_slot.slot_owner == NewSlots.SlotOwner.PLAYER:
		slot_side = "player slot"
	else:
		slot_side = "opponent slot"

	if card_owner == Owner.PLAYER:
		card_side = "player card"
	else:
		card_side = "opponent card"

	print(card_name, " -> ", slot_side, " / ", card_side)
	
	

func return_to_hand() -> void:
	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	if player_hand != null:
		player_hand.add_card_to_hand(self)

	set_selected(false)
