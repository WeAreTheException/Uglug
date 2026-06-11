extends Node2D
class_name Hand_Layout

enum LayoutMode {
	IDLE,
	PLAY,
	BLESSING
}

@export var idle_layout: Hand_IdleLayout
@export var play_layout: Hand_PlayLayout
@export var blessing_layout: Hand_BlessingLayout
@export var layout_tweener: Hand_LayoutTweener

@export var move_time: float = 0.15
@export var hand_width_reference: float = 550.0
@export var normal_z_start: int = 0

var current_mode: LayoutMode = LayoutMode.IDLE
var exclusion := HandLayoutExclusionHelper.new()
var index_resolver := HandInsertIndexResolverHelper.new()


func set_layout_mode(mode: LayoutMode) -> void:
	current_mode = mode


func arrange_cards(cards: Array[CardRoot]) -> void:
	var layout_cards := _get_layout_cards(cards)

	for i in range(layout_cards.size()):
		_arrange_card(layout_cards[i], i, layout_cards.size())


func set_ignored_card(card: CardRoot) -> void:
	exclusion.set_ignored_card(card)


func clear_ignored_card() -> void:
	exclusion.clear_ignored_card()


func set_primed_card(card: CardRoot) -> void:
	exclusion.set_primed_card(card)


func clear_primed_card() -> void:
	exclusion.clear_primed_card()


func get_insert_index_from_global_x(global_x: float, cards: Array[CardRoot]) -> int:
	return index_resolver.get_insert_index_from_global_x(
		global_x,
		cards,
		global_position,
		_get_card_spacing(),
		exclusion
	)


func _arrange_card(card: CardRoot, index: int, count: int) -> void:
	var card_spacing: float = _get_card_spacing()
	var total_width: float = card_spacing * float(count - 1)
	var start_x: float = -total_width / 2.0
	var x_pos: float = start_x + card_spacing * index

	var normalization_width: float = hand_width_reference

	if current_mode == LayoutMode.BLESSING:
		normalization_width = max(total_width / 2.0, 1.0)

	var normalized_x: float = clampf(
		x_pos / normalization_width,
		-1.0,
		1.0
	)

	var y_pos: float = 0.0

	if current_mode == LayoutMode.BLESSING:
		y_pos = (1.0 - normalized_x * normalized_x) * _get_curve_height()
	else:
		y_pos = -(1.0 - normalized_x * normalized_x) * _get_curve_height()

	y_pos += _get_y_offset()

	var target_position: Vector2 = global_position + Vector2(x_pos, y_pos)
	var target_rotation: float = normalized_x * _get_max_rotation_degrees()

	if layout_tweener != null:
		layout_tweener.tween_card(
			card,
			target_position,
			target_rotation,
			_get_target_scale(),
			normal_z_start + index,
			move_time
		)


func _get_layout_cards(cards: Array[CardRoot]) -> Array[CardRoot]:
	var result: Array[CardRoot] = []

	for card in cards:
		if exclusion.should_include(card):
			result.append(card)

	return result


func _get_active_layout() -> Node:
	match current_mode:
		LayoutMode.PLAY:
			return play_layout

		LayoutMode.BLESSING:
			return blessing_layout

	return idle_layout


func _get_card_spacing() -> float:
	var layout := _get_active_layout()
	return layout.card_spacing if layout != null else 110.0


func _get_curve_height() -> float:
	var layout := _get_active_layout()
	return layout.curve_height if layout != null else 0.0


func _get_max_rotation_degrees() -> float:
	var layout := _get_active_layout()
	return layout.max_rotation_degrees if layout != null else 0.0


func _get_target_scale() -> Vector2:
	var layout := _get_active_layout()
	return layout.target_scale if layout != null else Vector2.ONE


func _get_y_offset() -> float:
	if current_mode != LayoutMode.BLESSING:
		return 0.0

	if blessing_layout == null:
		return 0.0

	return blessing_layout.y_offset
