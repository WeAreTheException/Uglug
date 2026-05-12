extends Node2D
class_name MutationInstance

@export var sprite: Sprite2D

var mutation: Mutation = null
var target_hand: NewPlayerHand = null
var phase_manager: PhaseManager = null
var used: bool = false

func _ready() -> void:
	if sprite == null:
		sprite = get_node_or_null("Sprite2D") as Sprite2D

	phase_manager = get_tree().current_scene.find_child("PhaseManager", true, false) as PhaseManager

	if phase_manager != null:
		phase_manager.phase_changed.connect(_on_phase_changed)

func setup_mutation(new_mutation: Mutation, new_target_hand: NewPlayerHand = null) -> void:
	mutation = new_mutation
	target_hand = new_target_hand

	if sprite == null:
		sprite = get_node_or_null("Sprite2D") as Sprite2D

	if mutation == null:
		print("MutationInstance blocked: mutation is null")
		return

	if sprite == null:
		print("MutationInstance blocked: Sprite2D missing")
		return

	if mutation.sigil_texture == null:
		print("MutationInstance blocked: mutation sigil_texture is null")
		return

	sprite.texture = mutation.sigil_texture
	sprite.visible = true

func _on_phase_changed(phase_name: String) -> void:
	if used:
		return

	if phase_name == "Buff":
		return

	auto_apply_to_random_card()

func auto_apply_to_random_card() -> void:
	if used:
		return

	if mutation == null:
		print("auto buff blocked: mutation is null")
		queue_free()
		return

	var target_card := get_auto_target_card()

	if target_card == null:
		print("auto buff blocked: no selected card and no cards in hand")
		queue_free()
		return

	used = true

	var board_manager := get_tree().current_scene.find_child("BoardManager", true, false) as BoardManager

	if board_manager != null:
		board_manager.request_add_mutation_to_card(target_card, mutation)
	else:
		target_card.add_additional_mutation(mutation)

	queue_free()

func get_auto_target_card() -> Card:
	var selected_card := SelectHandler.selected_card

	if selected_card != null:
		if selected_card.card_owner == Card.Owner.PLAYER and selected_card.current_slot == null:
			return selected_card

	if target_hand == null:
		print("auto buff warning: target_hand is null")
		return null

	return target_hand.get_random_card()
