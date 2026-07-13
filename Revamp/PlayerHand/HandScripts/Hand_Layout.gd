extends Node2D
class_name Hand_Layout

enum LayoutMode {
	IDLE,
	PLAY,
	BLESSING,
	BUFF
}

@export var idle_layout: Hand_IdleLayout
@export var play_layout: Hand_PlayLayout
@export var blessing_layout: Hand_BlessingLayout
@export var buffing_layout: Hand_BuffingLayout
@export var layout_tweener: Hand_LayoutTweener

@export var hand_card_scale: Vector2 = Vector2(0.8, 0.8)
@export var move_time: float = 0.15
@export var normal_card_z: int = 0

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
	if not is_instance_valid(card):
		return

	var card_spacing: float = _get_card_spacing()
	var total_width: float = card_spacing * float(count - 1)
	var start_x: float = -total_width / 2.0
	var x_pos: float = start_x + card_spacing * index

	var target_position: Vector2 = global_position + Vector2(x_pos, _get_y_offset())
	var target_rotation: float = 0.0

	if layout_tweener != null:
		layout_tweener.tween_card(
			card,
			target_position,
			target_rotation,
			hand_card_scale,
			normal_card_z,
			move_time
		)


func _get_layout_cards(cards: Array[CardRoot]) -> Array[CardRoot]:
	var result: Array[CardRoot] = []

	for card in cards:
		if not is_instance_valid(card):
			continue

		if exclusion.should_include(card):
			result.append(card)

	return result


func _get_active_layout() -> Node:
	match current_mode:
		LayoutMode.PLAY:
			return play_layout
		LayoutMode.BLESSING:
			return blessing_layout if blessing_layout != null else idle_layout
		LayoutMode.BUFF:
			return buffing_layout if buffing_layout != null else idle_layout

	return idle_layout


func _get_card_spacing() -> float:
	var layout := _get_active_layout()
	return layout.card_spacing if layout != null else 150.0


func _get_y_offset() -> float:
	var layout := _get_active_layout()

	if layout == null:
		return 0.0

	if "y_offset" in layout:
		return layout.y_offset

	return 0.0
