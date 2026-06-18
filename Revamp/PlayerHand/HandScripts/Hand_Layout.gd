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

@export var move_time: float = 0.15
@export var hand_width_reference: float = 550.0
@export var normal_z_start: int = 0

@export var enable_debug_layout_keys: bool = false
@export var debug_idle_key: Key = KEY_1
@export var debug_play_key: Key = KEY_2
@export var debug_blessing_key: Key = KEY_3
@export var debug_buff_key: Key = KEY_4

var current_mode: LayoutMode = LayoutMode.IDLE
var exclusion := HandLayoutExclusionHelper.new()
var index_resolver := HandInsertIndexResolverHelper.new()


func _unhandled_input(event: InputEvent) -> void:
	if not enable_debug_layout_keys:
		return

	if not event is InputEventKey:
		return

	if not event.pressed:
		return

	if event.echo:
		return

	if event.keycode == debug_idle_key:
		set_layout_mode(LayoutMode.IDLE)
		_request_arrange_from_parent()
		print("DEBUG HAND LAYOUT: IDLE")
		return

	if event.keycode == debug_play_key:
		set_layout_mode(LayoutMode.PLAY)
		_request_arrange_from_parent()
		print("DEBUG HAND LAYOUT: PLAY")
		return

	if event.keycode == debug_blessing_key:
		set_layout_mode(LayoutMode.BLESSING)
		_request_arrange_from_parent()
		print("DEBUG HAND LAYOUT: BLESSING")
		return

	if event.keycode == debug_buff_key:
		set_layout_mode(LayoutMode.BUFF)
		_request_arrange_from_parent()
		print("DEBUG HAND LAYOUT: BUFF")
		return


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

	var normalization_width: float = hand_width_reference

	if _uses_upward_phase_layout():
		normalization_width = max(total_width / 2.0, 1.0)

	var normalized_x: float = clampf(
		x_pos / normalization_width,
		-1.0,
		1.0
	)

	var y_pos: float = 0.0

	if _uses_upward_phase_layout():
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
			return blessing_layout

		LayoutMode.BUFF:
			return buffing_layout

	return idle_layout


func _uses_upward_phase_layout() -> bool:
	return current_mode == LayoutMode.BLESSING or current_mode == LayoutMode.BUFF


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
	var layout := _get_active_layout()

	if layout == null:
		return 0.0

	if "y_offset" in layout:
		return layout.y_offset

	return 0.0


func _request_arrange_from_parent() -> void:
	var parent := get_parent()

	if parent == null:
		return

	if parent.has_method("arrange_cards"):
		parent.arrange_cards()
