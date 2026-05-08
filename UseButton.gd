extends Button
class_name UseButton

@export var disabled_modulate: Color = Color(0.5, 0.5, 0.5, 1.0)
@export var enabled_modulate: Color = Color(1, 1, 1, 1)

var mutation_instance: MutationInstance = null

func _ready() -> void:
	mutation_instance = get_parent() as MutationInstance
	set_usable(false)

func _process(_delta: float) -> void:
	set_usable(SelectHandler.selected_card != null)

func set_usable(value: bool) -> void:
	disabled = not value
	modulate = enabled_modulate if value else disabled_modulate

func _pressed() -> void:
	if disabled:
		return

	if mutation_instance == null:
		return

	if mutation_instance.mutation == null:
		return

	var selected_card := SelectHandler.selected_card

	if selected_card == null:
		return

	selected_card.add_additional_mutation(mutation_instance.mutation)

	mutation_instance.queue_free()
