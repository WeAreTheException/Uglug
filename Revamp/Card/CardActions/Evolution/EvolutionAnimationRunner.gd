extends Node
class_name EvolutionAnimationRunner

signal animation_finished

@export_group("Rise")
@export var jump_height: float = 40.0
@export var peak_scale_multiplier: float = 1.15
@export var rise_time: float = 0.16

@export_group("Landing")
@export var landing_offset: float = 5.0
@export var landing_scale_multiplier: float = 0.97
@export var fall_time: float = 0.14
@export var settle_time: float = 0.12

@export_group("Hand Reaction")
@export var open_time: float = 0.12

var active_tween: Tween = null

var stored_cards: Array[CardRoot] = []
var stored_rest_positions: Array[Vector2] = []

var stored_evolved_card: CardRoot = null
var stored_rest_scale: Vector2 = Vector2.ONE
var stored_rest_z: int = 0


func play(
	cards: Array[CardRoot],
	evolved_card: CardRoot,
	rest_positions: Array[Vector2],
	spread_positions: Array[Vector2],
	rest_scale: Vector2,
	z_value: int
) -> void:
	if evolved_card == null:
		return

	if not is_instance_valid(evolved_card):
		return

	if cards.is_empty():
		return

	if cards.size() != rest_positions.size():
		return

	if cards.size() != spread_positions.size():
		return

	var evolved_index := cards.find(evolved_card)

	if evolved_index < 0:
		return

	cancel()

	stored_cards.append_array(cards)
	stored_rest_positions.append_array(rest_positions)

	stored_evolved_card = evolved_card
	stored_rest_scale = rest_scale
	stored_rest_z = z_value

	_prepare_cards()

	var rest_position := rest_positions[evolved_index]
	var peak_position := rest_position + Vector2.UP * jump_height
	var landing_position := rest_position + Vector2.DOWN * landing_offset

	var peak_scale := rest_scale * peak_scale_multiplier
	var landing_scale := rest_scale * landing_scale_multiplier

	active_tween = create_tween()

	_tween_hand_open(spread_positions)

	active_tween.chain().tween_property(
		evolved_card,
		"global_position",
		peak_position,
		rise_time
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	active_tween.parallel().tween_property(
		evolved_card,
		"scale",
		peak_scale,
		rise_time
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	active_tween.chain().tween_property(
		evolved_card,
		"global_position",
		landing_position,
		fall_time
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN
	)

	active_tween.parallel().tween_property(
		evolved_card,
		"scale",
		landing_scale,
		fall_time
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN
	)

	_tween_hand_closed()

	active_tween.parallel().tween_property(
		evolved_card,
		"scale",
		rest_scale,
		settle_time
	).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(
		Tween.EASE_OUT
	)

	active_tween.tween_callback(_finish)


func cancel() -> void:
	if active_tween != null:
		if active_tween.is_valid():
			active_tween.kill()

	_restore_cards()
	_clear_state()


func is_playing() -> bool:
	return active_tween != null


func _prepare_cards() -> void:
	for i in range(stored_cards.size()):
		var card := stored_cards[i]

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		card.global_position = stored_rest_positions[i]
		card.z_index = stored_rest_z

		if card == stored_evolved_card:
			card.scale = stored_rest_scale
			card.z_index = stored_rest_z + 10


func _tween_hand_open(
	spread_positions: Array[Vector2]
) -> void:
	var first_tween := true

	for i in range(stored_cards.size()):
		var card := stored_cards[i]

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if first_tween:
			active_tween.tween_property(
				card,
				"global_position",
				spread_positions[i],
				open_time
			).set_trans(
				Tween.TRANS_CUBIC
			).set_ease(
				Tween.EASE_OUT
			)

			first_tween = false
		else:
			active_tween.parallel().tween_property(
				card,
				"global_position",
				spread_positions[i],
				open_time
			).set_trans(
				Tween.TRANS_CUBIC
			).set_ease(
				Tween.EASE_OUT
			)


func _tween_hand_closed() -> void:
	var first_tween := true

	for i in range(stored_cards.size()):
		var card := stored_cards[i]

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if first_tween:
			active_tween.chain().tween_property(
				card,
				"global_position",
				stored_rest_positions[i],
				settle_time
			).set_trans(
				Tween.TRANS_CUBIC
			).set_ease(
				Tween.EASE_OUT
			)

			first_tween = false
		else:
			active_tween.parallel().tween_property(
				card,
				"global_position",
				stored_rest_positions[i],
				settle_time
			).set_trans(
				Tween.TRANS_CUBIC
			).set_ease(
				Tween.EASE_OUT
			)


func _finish() -> void:
	_restore_cards()
	_clear_state()
	animation_finished.emit()


func _restore_cards() -> void:
	for i in range(stored_cards.size()):
		if i >= stored_rest_positions.size():
			continue

		var card := stored_cards[i]

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		card.global_position = stored_rest_positions[i]
		card.z_index = stored_rest_z

	if stored_evolved_card != null:
		if is_instance_valid(stored_evolved_card):
			stored_evolved_card.scale = stored_rest_scale
			stored_evolved_card.z_index = stored_rest_z


func _clear_state() -> void:
	active_tween = null
	stored_cards.clear()
	stored_rest_positions.clear()

	stored_evolved_card = null
	stored_rest_scale = Vector2.ONE
	stored_rest_z = 0
