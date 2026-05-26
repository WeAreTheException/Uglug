extends Node2D
class_name Card

enum Owner {
	PLAYER,
	OPPONENT
}

@export var card_stats: CardStats
@export var test_data: CardData
@export var card_art: CardArt

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

var slot_handler: CardSlotHandler = null
var state_machine: CardStateMachine = null
var attack_handler: AttackHandler = null
var hurt_handler: HurtHandler = null
var die_handler: DieHandler = null
var mutation_handler: MutationHandler = null


func _ready() -> void:
	add_to_group("cards")

	if card_stats == null:
		card_stats = get_node_or_null("CardStats") as CardStats

	if card_art == null:
		card_art = get_node_or_null("CardArt") as CardArt

	slot_handler = get_node_or_null("CardSlotHandler") as CardSlotHandler
	mutation_handler = get_node_or_null("MutationHandler") as MutationHandler

	state_machine = get_node_or_null("CardStateMachine") as CardStateMachine
	attack_handler = get_node_or_null("CardStateMachine/Attack") as AttackHandler
	hurt_handler = get_node_or_null("CardStateMachine/Hurt") as HurtHandler
	die_handler = get_node_or_null("CardStateMachine/Die") as DieHandler

	if test_data != null:
		setup_card(test_data)


func setup_card(data: CardData) -> void:
	if data == null:
		return

	card_name = data.name

	if card_stats != null:
		card_stats.setup_from_card_data(data)

	if card_art != null:
		card_art.set_ant_texture(data.ant_texture)

	if mutation_handler != null:
		mutation_handler.setup_from_card_data(data)
	else:
		base_mutations.clear()

		for mutation in data.base_mutations:
			if mutation == null:
				continue

			base_mutations.append(mutation.duplicate(true))

		additional_mutations.clear()
		update_sigils()


func add_additional_mutation(mutation: Mutation) -> void:
	if mutation_handler != null:
		mutation_handler.add_additional_mutation(mutation)
		return

	if mutation == null:
		return

	additional_mutations.append(mutation.duplicate(true))
	update_sigils()
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
		return

	if card_art == null:
		return

	card_art.clear_base_sigils()
	card_art.clear_additional_sigils()

	for i in range(base_mutations.size()):
		var mutation := base_mutations[i]

		if mutation == null:
			continue

		card_art.set_base_sigil(i, mutation.sigil_texture)

	for i in range(additional_mutations.size()):
		var mutation := additional_mutations[i]

		if mutation == null:
			continue

		card_art.set_additional_sigil(i, mutation.sigil_texture)


func get_main_sprite() -> Sprite2D:
	if card_art != null and card_art.card_image != null:
		return card_art.card_image

	var found := find_children("*", "Sprite2D", true, false)

	if found.size() <= 0:
		return null

	return found[0] as Sprite2D


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


func set_selected(value: bool) -> void:
	is_selected = value


func place_into_slot(slot: NewSlots) -> void:
	if slot_handler != null:
		slot_handler.place_into_slot(slot)


func animate_to_position(target_pos: Vector2) -> void:
	if slot_handler != null:
		slot_handler.animate_to_position(target_pos)


func apply_slot_owner(slot: NewSlots) -> void:
	if slot_handler != null:
		slot_handler.apply_slot_owner(slot)


func return_to_hand() -> void:
	if slot_handler != null:
		slot_handler.return_to_hand()
