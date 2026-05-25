extends Node2D
class_name Card

enum Owner {
	PLAYER,
	OPPONENT
}

@export var input_listener: CardInputListener
@export var card_stats: CardStats
@export var test_data: CardData
@export var base_sigil_container: Node2D
@export var additional_sigil_container: Node2D

var select_handler: SelectHandler = null
var battle_scale: BattleScale = null
var combat_manager: CombatManager = null

var current_attack: int:
	get:
		return card_stats.current_attack if card_stats != null else 0
	set(value):
		if card_stats != null:
			card_stats.set_attack(value)

var current_health: int:
	get:
		return card_stats.current_health if card_stats != null else 0
	set(value):
		if card_stats != null:
			card_stats.set_health(value)

var current_cost: int:
	get:
		return card_stats.current_cost if card_stats != null else 0
	set(value):
		if card_stats != null:
			card_stats.set_cost(value)

var current_worth: int:
	get:
		return card_stats.current_worth if card_stats != null else 0
	set(value):
		if card_stats != null:
			card_stats.set_worth(value)

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

var base_mutations: Array[Mutation] = []
var additional_mutations: Array[Mutation] = []

var death_processed: bool = false

var move_tween: Tween = null

var sacrifice_hint_active: bool = false
var sacrifice_hint_time: float = 0.0

var selection_visual_handler: CardSelectionVisualHandler = null
var state_machine: CardStateMachine = null
var attack_handler: AttackHandler = null
var hurt_handler: HurtHandler = null
var die_handler: DieHandler = null
var mutation_handler: MutationHandler = null


func _ready() -> void:
	add_to_group("cards")

	if card_stats == null:
		card_stats = get_node_or_null("CardStats") as CardStats

	selection_visual_handler = get_node_or_null("CardSelectionVisualHandler") as CardSelectionVisualHandler
	mutation_handler = get_node_or_null("MutationHandler") as MutationHandler

	state_machine = get_node_or_null("CardStateMachine") as CardStateMachine
	attack_handler = get_node_or_null("CardStateMachine/Attack") as AttackHandler
	hurt_handler = get_node_or_null("CardStateMachine/Hurt") as HurtHandler
	die_handler = get_node_or_null("CardStateMachine/Die") as DieHandler

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

	if card_stats != null:
		card_stats.setup_from_card_data(data)

	if mutation_handler != null:
		mutation_handler.setup_from_card_data(data)
	else:
		base_mutations.clear()

		for mutation in data.base_mutations:
			if mutation == null:
				continue

			base_mutations.append(mutation.duplicate(true))

		additional_mutations.clear()


func add_additional_mutation(mutation: Mutation) -> void:
	if mutation_handler != null:
		mutation_handler.add_additional_mutation(mutation)
		return

	if mutation == null:
		return

	additional_mutations.append(mutation.duplicate(true))
	print(card_name, " gained mutation")


func add_additional_mutation_from_path(mutation_path: String) -> void:
	if mutation_handler != null:
		mutation_handler.add_additional_mutation_from_path(mutation_path)
		return

	if mutation_path == "":
		return

	var mutation := load(mutation_path) as Mutation

	if mutation == null:
		print("add mutation blocked: could not load ", mutation_path)
		return

	add_additional_mutation(mutation)


func get_additional_mutation_paths() -> Array[String]:
	if mutation_handler != null:
		return mutation_handler.get_additional_mutation_paths()

	var paths: Array[String] = []

	for mutation in additional_mutations:
		if mutation == null:
			continue

		if mutation.resource_path == "":
			continue

		paths.append(mutation.resource_path)

	return paths


func get_all_mutations() -> Array[Mutation]:
	if mutation_handler != null:
		return mutation_handler.get_all_mutations()

	var combined: Array[Mutation] = []

	for mutation in base_mutations:
		if mutation != null:
			combined.append(mutation)

	for mutation in additional_mutations:
		if mutation != null:
			combined.append(mutation)

	return combined


func update_sigils() -> void:
	if mutation_handler != null:
		mutation_handler.update_sigils()


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

	if card_stats != null:
		card_stats.take_damage(amount)

	for mutation in get_all_mutations():
		if mutation != null:
			mutation.on_damaged(self, attacker, amount)

	if current_health <= 0:
		kill()


func discard() -> void:
	if current_slot != null:
		current_slot.clear_card()
		current_slot = null

	queue_free()


func kill() -> void:
	if die_handler != null:
		die_handler.die()
		return

	if death_processed:
		return

	death_processed = true
	current_health = 0

	for mutation in get_all_mutations():
		if mutation != null:
			mutation.on_death(self)

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

	if selection_visual_handler != null:
		selection_visual_handler.set_selected(value)


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
