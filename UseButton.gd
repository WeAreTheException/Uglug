extends Button
class_name UseButton

@export var disabled_modulate: Color = Color(0.5, 0.5, 0.5, 1.0)
@export var enabled_modulate: Color = Color(1, 1, 1, 1)

var mutation_instance: MutationInstance = null

func _ready() -> void:
	mutation_instance = get_parent() as MutationInstance
	set_usable(true)

func _process(_delta: float) -> void:
	set_usable(true)

func set_usable(value: bool) -> void:
	disabled = not value
	modulate = enabled_modulate if value else disabled_modulate

func _pressed() -> void:
	if disabled:
		return

	if mutation_instance == null:
		print("use button blocked: mutation_instance is null")
		return

	if mutation_instance.used:
		return

	if mutation_instance.mutation == null:
		print("use button blocked: mutation is null")
		return

	var target_card := get_target_card()

	if target_card == null:
		print("use button blocked: no selected card and no cards in hand")
		return

	mutation_instance.used = true

	var board_manager := get_tree().current_scene.find_child("BoardManager", true, false) as BoardManager

	if board_manager != null:
		board_manager.request_add_mutation_to_card(target_card, mutation_instance.mutation)
	else:
		print("use button warning: BoardManager not found, applying mutation locally")
		target_card.add_additional_mutation(mutation_instance.mutation)

	mutation_instance.queue_free()

func get_target_card() -> Card:
	var selected_card := SelectHandler.selected_card

	if selected_card != null:
		return selected_card

	if mutation_instance == null:
		return null

	if mutation_instance.target_hand == null:
		print("use button blocked: target_hand is null")
		return null

	return mutation_instance.target_hand.get_random_card()
