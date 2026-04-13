extends Node2D
class_name Card

@export var input_listener: CardInputListener
@export var drag_handler: CardDragHandler
@export var card_sprite: Sprite2D
@export var attack: RichTextLabel
@export var health: RichTextLabel
@export var cost: Array[Sprite2D]

var player_hand: Node2D = null
var current_slot: NewSlots = null
var overlapping_slot: NewSlots = null
var hand_position: Vector2
var is_hovered: bool = false

var card_name: String = ""
var card_data: Dictionary = {}

func _ready() -> void:
	if input_listener != null:
		input_listener.hovered.connect(_on_hovered)
		input_listener.hovered_off.connect(_on_hovered_off)
		input_listener.pressed.connect(_on_pressed)
		input_listener.released.connect(_on_released)
		input_listener.slot_entered.connect(_on_slot_entered)
		input_listener.slot_exited.connect(_on_slot_exited)

func setup_card(new_card_name: String, new_card_data: Dictionary) -> void:
	card_name = new_card_name
	card_data = new_card_data

	update_sprite_display()
	update_attack_display()
	update_health_display()
	update_cost_display()

func update_sprite_display() -> void:
	if card_sprite == null:
		return

	if not card_data.has("sprite_path"):
		return

	var texture = load(card_data["sprite_path"])
	if texture != null:
		card_sprite.texture = texture

func update_attack_display() -> void:
	if attack != null and card_data.has("attack"):
		attack.text = str(card_data["attack"])

func update_health_display() -> void:
	if health != null and card_data.has("health"):
		health.text = str(card_data["health"])

func update_cost_display() -> void:
	var card_cost: int = 0

	if card_data.has("cost"):
		card_cost = card_data["cost"]

	for i in range(cost.size()):
		if cost[i] != null:
			cost[i].visible = i < card_cost

func _on_hovered(_listener) -> void:
	is_hovered = true

func _on_hovered_off(_listener) -> void:
	is_hovered = false

func _on_pressed(_listener) -> void:
	if drag_handler == null:
		return

	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	if player_hand != null:
		player_hand.remove_card_from_hand(self)

	drag_handler.start_drag(self)

func _on_released(_listener) -> void:
	if drag_handler == null:
		return

	drag_handler.stop_drag()

	if overlapping_slot != null:
		place_into_slot(overlapping_slot)
	else:
		return_to_hand()

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
