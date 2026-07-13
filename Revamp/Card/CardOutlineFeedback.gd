extends Node
class_name CardOutlineFeedback

@export var outline_target: CanvasItem

@export var hover_color: Color = Color.WHITE
@export var selected_color: Color = Color(0.2, 0.55, 1.0, 1.0)
@export var martyr_color: Color = Color(1.0, 0.15, 0.1, 1.0)

@export var shader_color_parameter: String = "outline_color"

var is_hovered: bool = false
var is_selected: bool = false
var is_martyr: bool = false


func _ready() -> void:
	_make_unique_material()
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


func _make_unique_material() -> void:
	if outline_target == null:
		return

	if outline_target.material == null:
		return

	outline_target.material = outline_target.material.duplicate()


func _refresh() -> void:
	if outline_target == null:
		return

	if is_martyr:
		_show_color(martyr_color)
		return

	if is_selected:
		_show_color(selected_color)
		return

	if is_hovered:
		_show_color(hover_color)
		return

	outline_target.visible = false


func _show_color(color: Color) -> void:
	outline_target.visible = true

	var shader_material := outline_target.material as ShaderMaterial

	if shader_material == null:
		outline_target.modulate = color
		return

	shader_material.set_shader_parameter(shader_color_parameter, color)
