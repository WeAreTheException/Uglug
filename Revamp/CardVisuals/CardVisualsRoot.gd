extends Node2D
class_name CardVisualsRoot

@export var main_visuals: CardMainVisuals
@export var mutation_visuals: CardMutationVisuals
@export var stats_visual: StatsVisuals
@export var viewport_display: ViewportDisplayController

var card: CardRoot = null

func setup_from_card(source_card: CardRoot) -> void:
	card = source_card
	if card == null:
		return
	setup_from_data(card.card_data, card.card_name)
	_setup_stats()
	_setup_mutations()

func setup_from_data(data: CardData, display_name: String = "") -> void:
	if data == null:
		return
	if main_visuals != null:
		main_visuals.setup_from_data(data)
	if stats_visual != null and card != null and card.functionality_root != null:
		stats_visual.setup_from_stats(card.functionality_root.stats, display_name)

func refresh_all() -> void:
	if card == null:
		return
	setup_from_card(card)

func _setup_stats() -> void:
	if card == null or stats_visual == null:
		return
	var root := card.functionality_root
	if root != null:
		stats_visual.setup_from_stats(root.stats, card.card_name)

func _setup_mutations() -> void:
	if card == null or card.functionality_root == null:
		return
	var mutations := card.functionality_root.mutations
	if mutations == null:
		return
	if not mutations.mutations_changed.is_connected(_on_mutations_changed):
		mutations.mutations_changed.connect(_on_mutations_changed)
	_on_mutations_changed()

func _on_mutations_changed() -> void:
	if mutation_visuals == null:
		return
	mutation_visuals.clear_all()
	if card != null and card.functionality_root != null:
		var mutations := card.functionality_root.mutations
		if mutations != null:
			mutation_visuals.display_runtimes(mutations.get_all_runtimes())
