extends Node2D
class_name Card

@export var test_data: CardData
@export var card_art: Node
@export var card_stats: Node

var card_name: String = ""
var current_slot = null
var overlapping_slot = null
var is_hovered: bool = false
var is_selected: bool = false
var card_owner = 0
var owning_peer_id: int = 0
var multiplayer_card_id: int = -1
var hand_position: Vector2

var base_mutations: Array[Mutation] = []
var additional_mutations: Array[Mutation] = []


func _ready() -> void:
	pass


func setup_card(data: CardData) -> void:
	if data == null:
		return

	test_data = data
	card_name = data.name


func get_all_mutations() -> Array[Mutation]:
	var result: Array[Mutation] = []

	for mutation in base_mutations:
		if mutation != null:
			result.append(mutation)

	for mutation in additional_mutations:
		if mutation != null:
			result.append(mutation)

	return result


func add_additional_mutation(mutation: Mutation) -> void:
	if mutation == null:
		return

	additional_mutations.append(mutation)


func take_damage(_amount: int, _attacker: Card = null) -> void:
	pass


func kill() -> void:
	queue_free()


func discard() -> void:
	queue_free()


func set_selected(value: bool) -> void:
	is_selected = value


func place_into_slot(_slot) -> void:
	pass


func animate_to_position(_target_pos: Vector2) -> void:
	pass


func apply_slot_owner(_slot) -> void:
	pass


func return_to_hand() -> void:
	pass
