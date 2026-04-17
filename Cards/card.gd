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

var card_scene: PackedScene = null
var worker_draw_handler: DeckDrawHandler = null
var quirk_tooltip: QuirkTooltip = null

var card_owner: Owner = Owner.PLAYER

var player_hand: Node2D = null
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

var quirk_turn_counter: int = 0
var training_arc_used: bool = false

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

	if is_hovered and quirk_tooltip != null and quirk != null:
		quirk_tooltip.move_tooltip(get_viewport().get_mouse_position())

func setup_card(data: CardData) -> void:
	if data == null:
		print("FAIL: setup_card got null data")
		return

	card_name = data.name
	current_attack = data.attack
	current_health = data.health
	current_cost = data.cost
	current_worth = data.worth
	quirk = data.quirk as CardQuirk

	update_sigil()

	print("setup: ", data.name, " id=", multiplayer_card_id)

	if stats != null:
		stats.setup_from_card_data(data)
	else:
		print("FAIL: stats is null on card")

func update_sigil() -> void:
	print("update_sigil called for ", card_name)

	if sigil_sprite == null:
		print("sigil failed: sigil_sprite is null")
		return

	if quirk == null:
		print("sigil: no quirk on ", card_name)
		sigil_sprite.texture = null
		sigil_sprite.visible = false
		return

	print("sigil quirk = ", quirk)

	if quirk.sigil_texture == null:
		print("sigil failed: quirk has no sigil texture")
		sigil_sprite.texture = null
		sigil_sprite.visible = false
		return

	sigil_sprite.texture = quirk.sigil_texture
	sigil_sprite.visible = true

	print("sigil applied for ", card_name)

func show_quirk_tooltip() -> void:
	if quirk_tooltip == null:
		return

	if quirk == null:
		quirk_tooltip.hide_tooltip()
		return

	var title_text: String = quirk.quirk_name
	var body_text: String = quirk.description

	if title_text.strip_edges() == "" and body_text.strip_edges() == "":
		quirk_tooltip.hide_tooltip()
		return

	quirk_tooltip.show_tooltip(
		title_text,
		body_text,
		get_viewport().get_mouse_position()
	)

func hide_quirk_tooltip() -> void:
	if quirk_tooltip == null:
		return

	quirk_tooltip.hide_tooltip()

func _on_pressed(_listener) -> void:
	print("card clicked: ", card_name, " / select_handler = ", select_handler)

	if select_handler == null:
		print("card press blocked: select_handler is null")
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
		return

	print(card_name, " (", current_health, " hp)")

func kill() -> void:
	if death_processed:
		return

	death_processed = true
	current_health = 0

	if stats != null:
		stats.update_health(current_health)

	print(card_name, " died")

	if quirk != null:
		quirk.on_death(self)

	hide_quirk_tooltip()

	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	queue_free()

func draw_worker_cards(amount: int) -> void:
	if worker_draw_handler == null:
		print("draw_worker_cards failed: worker_draw_handler is null")
		return

	if player_hand == null:
		print("draw_worker_cards failed: player_hand is null")
		return

	for i in range(amount):
		var success := worker_draw_handler.draw_card_to_hand(
			player_hand,
			worker_draw_handler.spawn_anchor,
			card_owner
		)

		if not success:
			print("draw_worker_cards stopped early at ", i)
			break

func spawn_card_to_hand(data: CardData) -> void:
	if data == null:
		print("spawn_card_to_hand failed: data null")
		return

	if card_scene == null:
		print("spawn_card_to_hand failed: card_scene null")
		return

	if player_hand == null:
		print("spawn_card_to_hand failed: player_hand null")
		return

	var new_card = card_scene.instantiate() as Card
	if new_card == null:
		print("spawn_card_to_hand failed: instantiated node is not Card")
		return

	new_card.player_hand = player_hand
	new_card.select_handler = select_handler
	new_card.battle_scale = battle_scale
	new_card.card_scene = card_scene
	new_card.worker_draw_handler = worker_draw_handler
	new_card.card_owner = card_owner
	new_card.quirk_tooltip = quirk_tooltip

	player_hand.add_child(new_card)
	new_card.setup_card(data)

	if player_hand.has_method("add_card_to_hand"):
		player_hand.add_card_to_hand(new_card)

func _on_hovered(_listener) -> void:
	is_hovered = true
	show_quirk_tooltip()

func _on_hovered_off(_listener) -> void:
	is_hovered = false
	hide_quirk_tooltip()

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

func heal(amount: int) -> void:
	current_health += amount

	if stats != null:
		stats.update_health(current_health)

	print(card_name, " healed for ", amount, " / hp = ", current_health)

func on_turn_end() -> void:
	if quirk != null:
		quirk.on_turn_end(self)

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
