extends Node2D
class_name Hand_Layout

enum LayoutMode {
	IDLE,
	PLAY
}

@export var idle_layout: Hand_IdleLayout
@export var play_layout: Hand_PlayLayout
@export var layout_exclusion: Hand_LayoutExclusion
@export var insert_index_resolver: Hand_InsertIndexResolver

var current_layout_mode: LayoutMode = LayoutMode.IDLE


func set_layout_mode(mode: LayoutMode) -> void:
	current_layout_mode = mode


func arrange_cards(cards: Array[CardRoot]) -> void:
	var layout_cards := _get_layout_cards(cards)

	match current_layout_mode:
		LayoutMode.IDLE:
			if idle_layout != null:
				idle_layout.arrange_cards(layout_cards, global_position)

		LayoutMode.PLAY:
			if play_layout != null:
				play_layout.arrange_cards(layout_cards, global_position)


func set_ignored_card(card: CardRoot) -> void:
	if layout_exclusion != null:
		layout_exclusion.set_ignored_card(card)


func clear_ignored_card() -> void:
	if layout_exclusion != null:
		layout_exclusion.clear_ignored_card()


func set_primed_card(card: CardRoot) -> void:
	if layout_exclusion != null:
		layout_exclusion.set_primed_card(card)


func clear_primed_card() -> void:
	if layout_exclusion != null:
		layout_exclusion.clear_primed_card()


func get_insert_index_from_global_x(global_x: float, cards: Array[CardRoot]) -> int:
	if insert_index_resolver == null:
		return 0

	return insert_index_resolver.get_insert_index(
		global_x,
		_get_layout_cards(cards),
		global_position,
		_get_current_spacing()
	)


func _get_layout_cards(cards: Array[CardRoot]) -> Array[CardRoot]:
	if layout_exclusion == null:
		return cards.duplicate()

	return layout_exclusion.filter_cards(cards)


func _get_current_spacing() -> float:
	if current_layout_mode == LayoutMode.PLAY and play_layout != null:
		return play_layout.card_spacing

	if idle_layout != null:
		return idle_layout.card_spacing

	return 100.0
