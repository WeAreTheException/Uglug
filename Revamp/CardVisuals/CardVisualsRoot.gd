extends Node2D
class_name CardVisualsRoot

@export var main_visuals: CardMainVisuals
@export var mutation_visuals: CardMutationVisuals
@export var stats_visual: StatsVisuals

var card: CardRoot = null


func setup_from_card(source_card: CardRoot) -> void:
	if source_card == null:
		return

	card = source_card

	if card.card_data != null:
		setup_from_card_data(card.card_data)

	if card.stats != null and stats_visual != null:
		stats_visual.setup_from_stats(card.stats, card.card_name)

	if card.mutations != null:
		if not card.mutations.mutations_changed.is_connected(_on_mutations_changed):
			card.mutations.mutations_changed.connect(_on_mutations_changed)

	_update_mutation_visuals()


func setup_from_card_data(data: CardData) -> void:
	if data == null:
		return

	if main_visuals != null:
		main_visuals.set_ant_texture(data.ant_texture)


func set_card_texture(texture: Texture2D) -> void:
	if main_visuals != null:
		main_visuals.set_card_texture(texture)


func refresh_all() -> void:
	if card == null:
		return

	if card.card_data != null:
		setup_from_card_data(card.card_data)

	if card.stats != null and stats_visual != null:
		stats_visual.setup_from_stats(card.stats, card.card_name)

	_update_mutation_visuals()


func _on_mutations_changed() -> void:
	_update_mutation_visuals()


func _update_mutation_visuals() -> void:
	if mutation_visuals == null:
		return

	if card == null:
		mutation_visuals.clear_all()
		return

	if card.mutations == null:
		mutation_visuals.clear_all()
		return

	mutation_visuals.display_runtimes(card.mutations.get_all_runtimes())
