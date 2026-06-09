extends Node
class_name CardState

signal state_changed

var card: CardRoot = null
var card_owner: int = 0
var zone: String = CardZone.NONE
var is_hovered: bool = false
var is_selected: bool = false
var is_dragging: bool = false
var is_attacking: bool = false
var is_hurting: bool = false
var is_dying: bool = false
var is_dead: bool = false
var is_marked_for_sacrifice: bool = false


func setup(source_card: CardRoot) -> void:
	card = source_card


func setup_from_data(_data: CardData) -> void:
	zone = CardZone.HAND
	is_dead = false
	state_changed.emit()


func set_card_owner(value: int) -> void:
	card_owner = value
	state_changed.emit()


func set_zone(value: String) -> void:
	zone = value
	state_changed.emit()


func set_hovered(value: bool) -> void:
	is_hovered = value
	state_changed.emit()


func set_selected(value: bool) -> void:
	is_selected = value
	state_changed.emit()


func set_dragging(value: bool) -> void:
	is_dragging = value
	state_changed.emit()


func set_attacking(value: bool) -> void:
	is_attacking = value
	state_changed.emit()


func set_hurting(value: bool) -> void:
	is_hurting = value
	state_changed.emit()


func set_dying(value: bool) -> void:
	is_dying = value
	state_changed.emit()


func set_marked_for_sacrifice(value: bool) -> void:
	is_marked_for_sacrifice = value
	state_changed.emit()


func set_dead(value: bool) -> void:
	is_dead = value
	state_changed.emit()


func can_use_hand_feedback() -> bool:
	return zone == CardZone.HAND and not is_dead
