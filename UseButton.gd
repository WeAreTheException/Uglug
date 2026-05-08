extends Button
class_name UseButton

@export var disabled_modulate: Color = Color(0.5, 0.5, 0.5, 1.0)
@export var enabled_modulate: Color = Color(1, 1, 1, 1)

var mutation_instance: MutationInstance = null

func _ready() -> void:
	mutation_instance = get_parent() as MutationInstance
	set_usable(false)

func _process(_delta: float) -> void:
	var has_selected_hand_card := SelectHandler.selected_card != null
	set_usable(has_selected_hand_card)

func set_usable(value: bool) -> void:
	disabled = not value
	modulate = enabled_modulate if value else disabled_modulate

func _pressed() -> void:
	if disabled:
		return

	if mutation_instance == null:
		print("use blocked: mutation_instance is null")
		return

	if mutation_instance.mutation == null:
		print("use blocked: mutation is null")
		return

	var selected_card := SelectHandler.selected_card
	if selected_card == null:
		print("use blocked: no selected card")
		return

	selected_card.add_additional_mutation(mutation_instance.mutation)

	print(selected_card.card_name, " gained mutation: ", mutation_instance.mutation.mutation_name)

	mutation_instance.queue_free()
