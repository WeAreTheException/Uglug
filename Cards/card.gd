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
@export var base_sigil_container: Node2D
@export var additional_sigil_container: Node2D
@export var combat_manager: CombatManager
@export var worker_deck_draw_handler: DeckDrawHandler

var additional_sigil_sprite: Sprite2D = null

var card_owner: Owner = Owner.PLAYER

var player_hand: Node = null
var current_slot: NewSlots = null
var overlapping_slot: NewSlots = null
var hand_position: Vector2

var card_name: String = ""
var multiplayer_card_id: int = -1
var owning_peer_id: int = 0

var is_hovered: bool = false
var is_selected: bool = false

var current_attack: int = 0
var current_health: int = 0
var current_cost: int = 0
var current_worth: int = 0

var base_mutations: Array[Mutation] = []
var additional_mutations: Array[Mutation] = []

var death_processed: bool = false

var move_tween: Tween = null
var scale_tween: Tween = null

var sacrifice_hint_active: bool = false
var sacrifice_hint_time: float = 0.0

var state_machine: CardStateMachine = null
var attack_handler: AttackHandler = null
var hurt_handler: HurtHandler = null
var die_handler: DieHandler = null

func _ready() -> void:
	add_to_group("cards")

	cache_sigil_nodes()
	if additional_sigil_sprite != null:
		additional_sigil_sprite.visible = false
		additional_sigil_sprite.z_index = 50

	state_machine = get_node_or_null("CardStateMachine") as CardStateMachine
	attack_handler = get_node_or_null("CardStateMachine/Attack") as AttackHandler
	hurt_handler = get_node_or_null("CardStateMachine/Hurt") as HurtHandler
	die_handler = get_node_or_null("CardStateMachine/Die") as DieHandler

	if additional_sigil_sprite != null:
		additional_sigil_sprite.z_index = 50

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

func cache_sigil_nodes() -> void:
	if additional_sigil_container != null:
		additional_sigil_sprite = additional_sigil_container.get_node_or_null("Sprite2D") as Sprite2D

func setup_card(data: CardData) -> void:
	if data == null:
		return

	cache_sigil_nodes()

	card_name = data.name
	current_attack = data.attack
	current_health = data.health
	current_cost = data.cost
	current_worth = data.worth

	base_mutations = data.base_mutations.duplicate()
	additional_mutations = []

	update_sigils()

	if stats != null:
		stats.setup_from_card_data(data)

func add_additional_mutation(mutation: Mutation) -> void:
	if mutation == null:
		return

	additional_mutations.append(mutation)

	update_sigils()

	print(card_name, " gained mutation")

func get_all_mutations() -> Array[Mutation]:
	var combined: Array[Mutation] = []

	for mutation in base_mutations:
		if mutation != null:
			combined.append(mutation)

	for mutation in additional_mutations:
		if mutation != null:
			combined.append(mutation)

	return combined

func update_sigils() -> void:
	update_base_sigils()
	update_additional_sigil()

func update_base_sigils() -> void:
	if base_sigil_container == null:
		return

	for child in base_sigil_container.get_children():
		child.queue_free()

	if base_mutations.size() <= 0:
		return

	var spacing := 36.0
	var start_x := -((base_mutations.size() - 1) * spacing) / 2.0

	for i in range(base_mutations.size()):
		var mutation := base_mutations[i]

		if mutation == null:
			continue

		if mutation.sigil_texture == null:
			continue

		var sigil := Sprite2D.new()

		sigil.texture = mutation.sigil_texture
		sigil.position = Vector2(start_x + (i * spacing), 0)
		sigil.z_index = 50

		base_sigil_container.add_child(sigil)

func update_additional_sigil() -> void:
	cache_sigil_nodes()

	if additional_sigil_sprite == null:
		print("additional sigil sprite missing on ", card_name)
		return

	if additional_mutations.size() <= 0:
		additional_sigil_sprite.visible = false
		return

	var mutation := additional_mutations[additional_mutations.size() - 1]

	if mutation == null:
		additional_sigil_sprite.visible = false
		return

	additional_sigil_sprite.visible = true
	additional_sigil_sprite.z_index = 50

	if mutation.sigil_texture != null:
		additional_sigil_sprite.texture = mutation.sigil_texture

func get_main_sprite() -> Sprite2D:
	var found := find_children("*", "Sprite2D", true, false)

	if found.size() <= 0:
		return null

	return found[0] as Sprite2D

func _on_pressed(_listener) -> void:
	print("card pressed: ", card_name)

	if select_handler == null:
		print("card pressed blocked: select_handler is null on ", card_name)
		return

	select_handler.select_card(self)

func take_damage(amount: int, attacker: Card = null) -> void:
	if hurt_handler != null:
		hurt_handler.take_damage(amount, attacker)
		return

	current_health -= amount

	if current_health < 0:
		current_health = 0

	if stats != null:
		stats.update_health(current_health)

	for mutation in base_mutations:
		if mutation != null:
			mutation.on_damaged(self, attacker, amount)

	for mutation in additional_mutations:
		if mutation != null:
			mutation.on_damaged(self, attacker, amount)

	if current_health <= 0:
		kill()

func kill() -> void:
	if die_handler != null:
		die_handler.die()
		return

	if death_processed:
		return

	death_processed = true
	current_health = 0

	if stats != null:
		stats.update_health(current_health)

	for mutation in base_mutations:
		if mutation != null:
			mutation.on_death(self)

	for mutation in additional_mutations:
		if mutation != null:
			mutation.on_death(self)

	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	queue_free()

func discard() -> void:
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

func draw_worker_cards(amount: int) -> void:
	var worker_draw_handler := find_worker_deck_draw_handler()

	if worker_draw_handler == null:
		print("draw worker blocked: could not find worker DeckDrawHandler")
		return

	for i in range(amount):
		worker_draw_handler.draw_player_card()

func find_worker_deck_draw_handler() -> DeckDrawHandler:
	var scene := get_tree().current_scene

	if scene == null:
		return null

	return find_worker_deck_draw_handler_recursive(scene)

func find_worker_deck_draw_handler_recursive(node: Node) -> DeckDrawHandler:
	var handler := node as DeckDrawHandler

	if handler != null:
		if handler.deck_type == DeckDrawHandler.DeckType.WORKER:
			return handler

	for child in node.get_children():
		var found := find_worker_deck_draw_handler_recursive(child)

		if found != null:
			return found

	return null
