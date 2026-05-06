extends Node2D
class_name Card

enum Owner {
	PLAYER,
	OPPONENT
}

@export var input_listener: CardInputListener
@export var select_handler: SelectHandler
@export var stats: Stats
@export var test_data: CardData
@export var battle_scale: BattleScale
@export var sigil_sprite: Sprite2D

var card_owner: Owner = Owner.PLAYER

var player_hand: Node = null
var current_slot: NewSlots = null
var overlapping_slot: NewSlots = null
var hand_position: Vector2

var card_name: String = ""
var multiplayer_card_id: int = -1

var is_hovered: bool = false
var is_selected: bool = false

var current_attack: int = 0
var current_health: int = 0
var current_cost: int = 0
var current_worth: int = 0

var quirk: CardQuirk = null
var death_processed: bool = false

var move_tween: Tween = null
var scale_tween: Tween = null

var sacrifice_hint_active: bool = false
var sacrifice_hint_time: float = 0.0

func _ready() -> void:
	if input_listener != null:
		input_listener.hovered.connect(_on_hovered)
		input_listener.hovered_off.connect(_on_hovered_off)
		input_listener.slot_entered.connect(_on_slot_entered)
		input_listener.slot_exited.connect(_on_slot_exited)
		input_listener.pressed.connect(_on_pressed)

	if test_data != null:
		setup_card(test_data)

func _process(delta: float) -> void:
	update_sacrifice_hint(delta)

func setup_card(data: CardData) -> void:
	if data == null:
		return

	card_name = data.name
	current_attack = data.attack
	current_health = data.health
	current_cost = data.cost
	current_worth = data.worth
	quirk = data.quirk as CardQuirk

	update_sigil()

	if stats != null:
		stats.setup_from_card_data(data)

func update_sigil() -> void:
	if sigil_sprite == null:
		return

	if quirk == null:
		sigil_sprite.texture = null
		sigil_sprite.visible = false
		return

	if quirk.sigil_texture == null:
		sigil_sprite.texture = null
		sigil_sprite.visible = false
		return

	sigil_sprite.texture = quirk.sigil_texture
	sigil_sprite.visible = true

func _on_pressed(_listener) -> void:
	print("card pressed: ", card_name)

	if select_handler == null:
		print("card pressed blocked: select_handler is null on ", card_name)
		return

	select_handler.select_card(self)

func take_damage(amount: int, attacker: Card = null) -> void:
	current_health -= amount

	if current_health < 0:
		current_health = 0

	if stats != null:
		stats.update_health(current_health)

	if quirk != null:
		quirk.on_damaged(self, attacker, amount)

	if current_health <= 0:
		kill()

func kill() -> void:
	if death_processed:
		return

	death_processed = true
	current_health = 0

	if stats != null:
		stats.update_health(current_health)

	if quirk != null:
		quirk.on_death(self)

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
		return

	if not slot.assign_card(self):
		return

	if current_slot != null and current_slot != slot:
		current_slot.clear_card()

	current_slot = slot

	if player_hand != null:
		if player_hand.has_method("remove_card_from_hand"):
			player_hand.remove_card_from_hand(self)

	animate_to_position(slot.global_position)

	apply_slot_owner(slot)

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

func return_to_hand() -> void:
	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	if player_hand != null:
		if player_hand.has_method("add_card_to_hand"):
			player_hand.add_card_to_hand(self)

	set_selected(false)

func start_sacrifice_hint() -> void:
	sacrifice_hint_active = true
	sacrifice_hint_time = 0.0

func stop_sacrifice_hint() -> void:
	sacrifice_hint_active = false
	sacrifice_hint_time = 0.0
	rotation = 0.0

func update_sacrifice_hint(delta: float) -> void:
	if not sacrifice_hint_active:
		return

	sacrifice_hint_time += delta
	rotation = sin(sacrifice_hint_time * 8.0) * deg_to_rad(3.0)
