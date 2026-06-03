extends Node2D
class_name HandLayout

@export var passive_card_spacing: float = 110.0
@export var active_card_spacing: float = 150.0

@export var move_time: float = 0.15

@export var passive_curve_height: float = 40.0
@export var active_curve_height: float = 0.0

@export var passive_max_rotation_degrees: float = 12.0
@export var active_max_rotation_degrees: float = 0.0

@export var passive_scale: Vector2 = Vector2.ONE
@export var active_scale: Vector2 = Vector2(1.08, 1.08)

@export var hand_width_reference: float = 550.0
@export var normal_z_start: int = 0

var ignored_card: CardRoot = null
var primed_card: CardRoot = null

var current_mode: PhaseManager.HandMode = PhaseManager.HandMode.HAND_PASSIVE


func set_hand_mode(mode: PhaseManager.HandMode) -> void:
	current_mode = mode


func arrange_cards(cards: Array[CardRoot]) -> void:
	var layout_cards: Array[CardRoot] = []

	for card in cards:
		if card == null:
			continue

		if card == ignored_card:
			continue

		if card == primed_card:
			continue

		layout_cards.append(card)

	if layout_cards.is_empty():
		return

	var card_spacing := _get_card_spacing()
	var curve_height := _get_curve_height()
	var max_rotation_degrees := _get_max_rotation_degrees()
	var target_scale := _get_target_scale()

	var total_width := card_spacing * float(layout_cards.size() - 1)
	var start_x := -total_width / 2.0

	for i in range(layout_cards.size()):
		var card := layout_cards[i]

		card.z_index = normal_z_start + i

		var x_pos := start_x + card_spacing * i

		var normalized_x := x_pos / hand_width_reference
		normalized_x = clampf(normalized_x, -1.0, 1.0)

		var y_pos := -(1.0 - normalized_x * normalized_x) * curve_height
		var rotation_deg := normalized_x * max_rotation_degrees

		var target_position := global_position + Vector2(x_pos, y_pos)

		var tween := card.create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)

		tween.parallel().tween_property(
			card,
			"global_position",
			target_position,
			move_time
		)

		tween.parallel().tween_property(
			card,
			"rotation_degrees",
			rotation_deg,
			move_time
		)

		tween.parallel().tween_property(
			card,
			"scale",
			target_scale,
			move_time
		)


func set_ignored_card(card: CardRoot) -> void:
	ignored_card = card


func clear_ignored_card() -> void:
	ignored_card = null


func set_primed_card(card: CardRoot) -> void:
	primed_card = card


func clear_primed_card() -> void:
	primed_card = null


func get_insert_index_from_global_x(global_x: float, cards: Array[CardRoot]) -> int:
	if cards.is_empty():
		return 0

	var layout_cards: Array[CardRoot] = []

	for card in cards:
		if card == null:
			continue

		if card == primed_card:
			continue

		layout_cards.append(card)

	if layout_cards.is_empty():
		return 0

	var card_spacing := _get_card_spacing()

	var total_width := card_spacing * float(layout_cards.size() - 1)
	var start_x := -total_width / 2.0
	var local_x := global_x - global_position.x

	var index := int(round((local_x - start_x) / card_spacing))

	return clampi(index, 0, layout_cards.size() - 1)


func _get_card_spacing() -> float:
	if current_mode == PhaseManager.HandMode.HAND_ACTIVE:
		return active_card_spacing

	return passive_card_spacing


func _get_curve_height() -> float:
	if current_mode == PhaseManager.HandMode.HAND_ACTIVE:
		return active_curve_height

	return passive_curve_height


func _get_max_rotation_degrees() -> float:
	if current_mode == PhaseManager.HandMode.HAND_ACTIVE:
		return active_max_rotation_degrees

	return passive_max_rotation_degrees


func _get_target_scale() -> Vector2:
	if current_mode == PhaseManager.HandMode.HAND_ACTIVE:
		return active_scale

	return passive_scale
