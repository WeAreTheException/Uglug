extends Node2D
class_name SigilSlot

signal hovered(slot: SigilSlot)
signal unhovered(slot: SigilSlot)
signal right_clicked(slot: SigilSlot)
signal left_clicked(slot: SigilSlot)

@export var sprite: Sprite2D
@export var input: SigilInput

@export var normal_outline_color: Color = Color(0.05, 0.05, 0.05, 1.0)
@export var hover_outline_color: Color = Color(1.0, 0.9, 0.25, 1.0)
@export var pressed_outline_color: Color = Color(1.0, 1.0, 1.0, 1.0)

@export var normal_line_thickness: float = 10.0
@export var hover_line_thickness: float = 10.0
@export var pressed_line_thickness: float = 12.0

@export var line_color_parameter: String = "line_color"
@export var line_thickness_parameter: String = "line_thickness"

var runtime: MutationRuntime = null
var mutation: Mutation = null

var is_hovered: bool = false
var is_pressed: bool = false
var unique_material: ShaderMaterial = null


func _ready() -> void:
	_connect_input()
	_prepare_unique_material()
	clear()


func setup_runtime(source_runtime: MutationRuntime, greyed_out_alpha: float) -> void:
	runtime = source_runtime
	mutation = null

	if runtime != null:
		mutation = runtime.mutation

	if mutation == null:
		clear()
		return

	visible = true
	_prepare_unique_material()

	if sprite != null:
		sprite.texture = mutation.sigil_texture
		sprite.visible = mutation.sigil_texture != null
		sprite.modulate.a = greyed_out_alpha if runtime.is_greyed_out else 1.0

	_set_input_enabled(true)
	_apply_normal_style()


func clear() -> void:
	runtime = null
	mutation = null
	is_hovered = false
	is_pressed = false

	if sprite != null:
		sprite.texture = null
		sprite.visible = false
		sprite.modulate.a = 1.0

	_set_input_enabled(false)
	visible = false


func get_mutation() -> Mutation:
	return mutation


func get_mutation_name() -> String:
	if mutation == null:
		return ""

	return mutation.mutation_name


func get_mutation_description() -> String:
	if mutation == null:
		return ""

	return mutation.mutation_description


func _connect_input() -> void:
	if input == null:
		return

	if not input.sigil_hovered.is_connected(_on_input_hovered):
		input.sigil_hovered.connect(_on_input_hovered)

	if not input.sigil_unhovered.is_connected(_on_input_unhovered):
		input.sigil_unhovered.connect(_on_input_unhovered)

	if not input.sigil_left_pressed.is_connected(_on_input_left_pressed):
		input.sigil_left_pressed.connect(_on_input_left_pressed)

	if not input.sigil_left_released.is_connected(_on_input_left_released):
		input.sigil_left_released.connect(_on_input_left_released)

	if not input.sigil_right_pressed.is_connected(_on_input_right_pressed):
		input.sigil_right_pressed.connect(_on_input_right_pressed)

	if not input.sigil_right_released.is_connected(_on_input_right_released):
		input.sigil_right_released.connect(_on_input_right_released)


func _prepare_unique_material() -> void:
	if sprite == null:
		return

	if unique_material != null:
		return

	var shader_material := sprite.material as ShaderMaterial

	if shader_material == null:
		return

	unique_material = shader_material.duplicate() as ShaderMaterial
	sprite.material = unique_material


func _set_input_enabled(value: bool) -> void:
	if input == null:
		return

	input.set_input_enabled(value)


func _on_input_hovered(_input: SigilInput) -> void:
	if mutation == null:
		return

	is_hovered = true

	if not is_pressed:
		_apply_hover_style()

	hovered.emit(self)


func _on_input_unhovered(_input: SigilInput) -> void:
	if mutation == null:
		return

	is_hovered = false
	is_pressed = false
	_apply_normal_style()
	unhovered.emit(self)


func _on_input_left_pressed(_input: SigilInput) -> void:
	if mutation == null:
		return

	is_pressed = true
	_apply_pressed_style()
	left_clicked.emit(self)


func _on_input_left_released(_input: SigilInput) -> void:
	if mutation == null:
		return

	is_pressed = false
	_apply_style_for_current_hover()


func _on_input_right_pressed(_input: SigilInput) -> void:
	if mutation == null:
		return

	is_pressed = true
	_apply_pressed_style()
	right_clicked.emit(self)


func _on_input_right_released(_input: SigilInput) -> void:
	if mutation == null:
		return

	is_pressed = false
	_apply_style_for_current_hover()


func _apply_style_for_current_hover() -> void:
	if is_hovered:
		_apply_hover_style()
	else:
		_apply_normal_style()


func _apply_normal_style() -> void:
	_set_outline_style(normal_outline_color, normal_line_thickness)


func _apply_hover_style() -> void:
	_set_outline_style(hover_outline_color, hover_line_thickness)


func _apply_pressed_style() -> void:
	_set_outline_style(pressed_outline_color, pressed_line_thickness)


func _set_outline_style(color: Color, thickness: float) -> void:
	if unique_material == null:
		_prepare_unique_material()

	if unique_material == null:
		return

	unique_material.set_shader_parameter(line_color_parameter, color)
	unique_material.set_shader_parameter(line_thickness_parameter, thickness)
