extends Node
class_name SlotPresetHandler

@export var card_scene: PackedScene
@export var spawn_parent: Node2D


func setup_presets(slot_pair: SlotPair) -> void:
	if slot_pair == null:
		return

	if slot_pair.player_starting_card != null:
		spawn_card_into_slot(
			slot_pair.player_starting_card,
			slot_pair.player_slot,
			Card.Owner.PLAYER
		)

	if slot_pair.opponent_starting_card != null:
		spawn_card_into_slot(
			slot_pair.opponent_starting_card,
			slot_pair.opponent_slot,
			Card.Owner.OPPONENT
		)


func spawn_card_into_slot(
	card_data: CardData,
	slot: NewSlots,
	owner: int
) -> Card:
	if card_scene == null:
		print("SlotPresetHandler blocked: card_scene is null")
		return null

	if card_data == null:
		print("SlotPresetHandler blocked: card_data is null")
		return null

	if slot == null:
		print("SlotPresetHandler blocked: slot is null")
		return null

	if not slot.is_empty():
		print("SlotPresetHandler blocked: slot already occupied: ", slot.name)
		return null

	var card := card_scene.instantiate() as Card

	if card == null:
		print("SlotPresetHandler blocked: card_scene root is not Card")
		return null

	var parent_node := spawn_parent

	if parent_node == null:
		parent_node = get_tree().current_scene as Node2D

	if parent_node == null:
		parent_node = get_parent() as Node2D

	parent_node.add_child(card)

	card.card_owner = owner
	card.global_position = slot.global_position
	card.current_slot = slot
	card.death_processed = false

	card.setup_card(card_data)

	if not slot.assign_card(card):
		card.queue_free()
		return null

	return card
