extends Node
class_name CardOutlineFeedback

@export var outline_target: CanvasItem

@export var hover_color: Color = Color.WHITE
@export var selected_color: Color = Color(0.2, 0.55, 1.0, 1.0)
@export var martyr_color: Color = Color(1.0, 0.15, 0.1, 1.0)

var is_hovered: bool = false
var is_selected: bool = false
var is_martyr: bool = false


func _ready() -> void:
	_refresh()


func set_hovered(value: bool) -> void:
	is_hovered = value
	_refresh()


func set_selected(value: bool) -> void:
	is_selected = value
	_refresh()


func set_martyr(value: bool) -> void:
	is_martyr = value
	_refresh()


func clear_all() -> void:
	is_hovered = false
	is_selected = false
	is_martyr = false
	_refresh()


func _refresh() -> void:
	if outline_target == null:
		return

	if is_martyr:
		outline_target.visible = true
		outline_target.modulate = martyr_color
		return

	if is_selected:
		outline_target.visible = true
		outline_target.modulate = selected_color
		return

	if is_hovered:
		outline_target.visible = true
		outline_target.modulate = hover_color
		return

	outline_target.visible = false
