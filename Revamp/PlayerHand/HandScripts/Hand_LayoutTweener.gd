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

	if _is_drag_locked(card):
		kill_card_tween(card)
		return

	card.z_index = z_value
	kill_card_tween(card)

	var tween := create_tween()
	active_tweens[card] = tween

	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(card, "global_position", target_position, move_time)
	tween.parallel().tween_property(card, "rotation_degrees", target_rotation_degrees, move_time)
	tween.parallel().tween_property(card, "scale", target_scale, move_time)

	tween.finished.connect(func() -> void:
		if active_tweens.get(card) == tween:
			active_tweens.erase(card)
	)


func kill_card_tween(card: CardRoot) -> void:
	if not active_tweens.has(card):
		return

	var tween := active_tweens[card] as Tween

	if tween != null:
		tween.kill()

	active_tweens.erase(card)


func _is_drag_locked(card: CardRoot) -> bool:
	if not card.has_meta(DRAG_LOCK_META):
		return false

	return bool(card.get_meta(DRAG_LOCK_META))
