extends Node
class_name Hand_LayoutTweener

const DRAG_LOCK_META := "hand_drag_locked"

var active_tweens: Dictionary = {}


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

	var card_id: int = card.get_instance_id()

	if _is_drag_locked(card):
		kill_card_tween(card)
		return

	kill_card_tween(card)

	var tween := create_tween()
	active_tweens[card_id] = tween

	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(card, "global_position", target_position, move_time)
	tween.parallel().tween_property(card, "rotation_degrees", target_rotation_degrees, move_time)
	tween.parallel().tween_property(card, "scale", target_scale, move_time)

	tween.finished.connect(_on_tween_finished.bind(card_id, tween))


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
	for tween in active_tweens.values():
		if tween == null:
			continue

		if tween is Tween:
			tween.kill()

	active_tweens.clear()


func _on_tween_finished(card_id: int, tween: Tween) -> void:
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
