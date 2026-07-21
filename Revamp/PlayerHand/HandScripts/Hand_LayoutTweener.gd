extends Node
class_name Hand_LayoutTweener

const DRAG_LOCK_META := "hand_drag_locked"

@export_group("Evolution Feedback")
@export var evolution_jump_height: float = 40.0
@export var evolution_peak_scale_multiplier: float = 1.15
@export var evolution_landing_offset: float = 5.0
@export var evolution_landing_scale_multiplier: float = 0.97

@export var evolution_open_time: float = 0.12
@export var evolution_rise_time: float = 0.16
@export var evolution_fall_time: float = 0.14
@export var evolution_settle_time: float = 0.12

var active_tweens: Dictionary = {}

var active_evolution_tween: Tween = null
var evolution_cards: Array[CardRoot] = []
var evolution_rest_positions: Array[Vector2] = []
var evolution_card: CardRoot = null
var evolution_rest_scale: Vector2 = Vector2.ONE
var evolution_rest_z: int = 0


func tween_card(
	card: CardRoot,
	target_position: Vector2,
	target_rotation_degrees: float,
	target_scale: Vector2,
	z_value: int,
	move_time: float
) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	if active_evolution_tween != null:
		_stop_evolution_tween(true)

	var card_id: int = card.get_instance_id()

	if _is_drag_locked(card):
		kill_card_tween(card)
		return

	kill_card_tween(card)

	var tween := create_tween()
	active_tweens[card_id] = tween

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
		target_rotation_degrees,
		move_time
	)

	tween.parallel().tween_property(
		card,
		"scale",
		target_scale,
		move_time
	)

	card.z_index = z_value

	tween.finished.connect(
		_on_tween_finished.bind(card_id, tween)
	)


func play_evolution_feedback(
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

	var evolved_index: int = cards.find(evolved_card)

	if evolved_index < 0:
		return

	clear_all_tweens()

	evolution_cards = cards.duplicate()
	evolution_rest_positions = rest_positions.duplicate()
	evolution_card = evolved_card
	evolution_rest_scale = rest_scale
	evolution_rest_z = z_value

	for card in evolution_cards:
		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		card.z_index = z_value

	evolved_card.z_index = z_value + 10

	var rest_position: Vector2 = rest_positions[evolved_index]
	var peak_position := (
		rest_position
		+ Vector2.UP * evolution_jump_height
	)
	var landing_position := (
		rest_position
		+ Vector2.DOWN * evolution_landing_offset
	)

	var peak_scale := (
		rest_scale
		* evolution_peak_scale_multiplier
	)
	var landing_scale := (
		rest_scale
		* evolution_landing_scale_multiplier
	)

	active_evolution_tween = create_tween()

	var first_open_tween: bool = true

	for i in range(cards.size()):
		var card := cards[i]

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if first_open_tween:
			active_evolution_tween.tween_property(
				card,
				"global_position",
				spread_positions[i],
				evolution_open_time
			).set_trans(
				Tween.TRANS_CUBIC
			).set_ease(
				Tween.EASE_OUT
			)

			first_open_tween = false
		else:
			active_evolution_tween.parallel().tween_property(
				card,
				"global_position",
				spread_positions[i],
				evolution_open_time
			).set_trans(
				Tween.TRANS_CUBIC
			).set_ease(
				Tween.EASE_OUT
			)

	active_evolution_tween.parallel().tween_property(
		evolved_card,
		"scale",
		rest_scale,
		evolution_open_time
	).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(
		Tween.EASE_OUT
	)

	active_evolution_tween.chain().tween_property(
		evolved_card,
		"global_position",
		peak_position,
		evolution_rise_time
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	active_evolution_tween.parallel().tween_property(
		evolved_card,
		"scale",
		peak_scale,
		evolution_rise_time
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	active_evolution_tween.chain().tween_property(
		evolved_card,
		"global_position",
		landing_position,
		evolution_fall_time
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN
	)

	active_evolution_tween.parallel().tween_property(
		evolved_card,
		"scale",
		landing_scale,
		evolution_fall_time
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN
	)

	var first_settle_tween: bool = true

	for i in range(cards.size()):
		var card := cards[i]

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		if first_settle_tween:
			active_evolution_tween.chain().tween_property(
				card,
				"global_position",
				rest_positions[i],
				evolution_settle_time
			).set_trans(
				Tween.TRANS_CUBIC
			).set_ease(
				Tween.EASE_OUT
			)

			first_settle_tween = false
		else:
			active_evolution_tween.parallel().tween_property(
				card,
				"global_position",
				rest_positions[i],
				evolution_settle_time
			).set_trans(
				Tween.TRANS_CUBIC
			).set_ease(
				Tween.EASE_OUT
			)

	active_evolution_tween.parallel().tween_property(
		evolved_card,
		"scale",
		rest_scale,
		evolution_settle_time
	).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(
		Tween.EASE_OUT
	)

	active_evolution_tween.tween_callback(
		_finish_evolution_tween
	)


func kill_card_tween(card: CardRoot) -> void:
	if card == null:
		return

	if not is_instance_valid(card):
		return

	var card_id: int = card.get_instance_id()

	if not active_tweens.has(card_id):
		return

	var tween := active_tweens[card_id] as Tween

	if tween != null:
		tween.kill()

	active_tweens.erase(card_id)


func clear_all_tweens() -> void:
	_stop_evolution_tween(true)

	for tween in active_tweens.values():
		if tween == null:
			continue

		if tween is Tween:
			tween.kill()

	active_tweens.clear()


func _finish_evolution_tween() -> void:
	_restore_evolution_rest_state()
	_clear_evolution_state()


func _stop_evolution_tween(
	restore_rest_state: bool
) -> void:
	if active_evolution_tween != null:
		if active_evolution_tween.is_valid():
			active_evolution_tween.kill()

	if restore_rest_state:
		_restore_evolution_rest_state()

	_clear_evolution_state()


func _restore_evolution_rest_state() -> void:
	for i in range(evolution_cards.size()):
		if i >= evolution_rest_positions.size():
			continue

		var card := evolution_cards[i]

		if card == null:
			continue

		if not is_instance_valid(card):
			continue

		card.global_position = evolution_rest_positions[i]
		card.z_index = evolution_rest_z

	if evolution_card != null:
		if is_instance_valid(evolution_card):
			evolution_card.scale = evolution_rest_scale
			evolution_card.z_index = evolution_rest_z


func _clear_evolution_state() -> void:
	active_evolution_tween = null
	evolution_cards.clear()
	evolution_rest_positions.clear()
	evolution_card = null
	evolution_rest_scale = Vector2.ONE
	evolution_rest_z = 0


func _on_tween_finished(
	card_id: int,
	tween: Tween
) -> void:
	if active_tweens.get(card_id) == tween:
		active_tweens.erase(card_id)


func _is_drag_locked(card: CardRoot) -> bool:
	if card == null:
		return false

	if not is_instance_valid(card):
		return false

	if not card.has_meta(DRAG_LOCK_META):
		return false

	return bool(card.get_meta(DRAG_LOCK_META))
