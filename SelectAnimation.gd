extends Node
class_name SelectAnimation

@export var selected_scale: Vector2 = Vector2(1.15, 1.15)
@export var normal_scale: Vector2 = Vector2(1.0, 1.0)
@export var tween_time: float = 0.12

var active_tweens: Dictionary = {}


func show_card_selected(card: Card) -> void:
	if card == null:
		return

	card.is_selected = true
	_tween_card_scale(card, selected_scale)


func show_card_unselected(card: Card) -> void:
	if card == null:
		return

	card.is_selected = false
	_tween_card_scale(card, normal_scale)


func clear_pending_visual(pending_play_card: Card) -> void:
	if pending_play_card == null:
		return

	show_card_unselected(pending_play_card)


func clear_sacrifice_visuals(sacrifice_handler: SacrificeHandler) -> void:
	if sacrifice_handler == null:
		return

	sacrifice_handler.clear_selected_sacrifice_visuals()


func _tween_card_scale(card: Card, target_scale: Vector2) -> void:
	if active_tweens.has(card):
		var old_tween: Tween = active_tweens[card]

		if old_tween != null:
			old_tween.kill()

	var tween := card.create_tween()
	active_tweens[card] = tween

	tween.tween_property(card, "scale", target_scale, tween_time)
