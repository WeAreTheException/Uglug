extends Node2D

@export var enabled: bool = true

@export_group("References")
@export var card_viewport: SubViewport
@export var card_display: Sprite2D

@export_group("Card Size")
@export var card_size: Vector2 = Vector2(144.0, 228.0)

@export_group("Tilt")
@export var max_x_rotation: float = 10.0
@export var max_y_rotation: float = 10.0
@export var tilt_speed: float = 12.0

@export_group("Hover Feel")
@export var hover_scale: float = 1.04
@export var scale_speed: float = 10.0
@export var reset_when_not_hovered: bool = true

var shader_material: ShaderMaterial = null

var current_x_rot: float = 0.0
var current_y_rot: float = 0.0
var start_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	_setup_viewport()
	_setup_shader_material()


func _process(delta: float) -> void:
	if shader_material == null:
		return

	if not enabled:
		_return_to_normal(delta)
		return

	if _is_mouse_over_card():
		_update_hover_tilt(delta)
	else:
		if reset_when_not_hovered:
			_return_to_normal(delta)


func _setup_viewport() -> void:
	if card_viewport == null:
		push_warning("CardMouseTiltRoot has no card_viewport assigned.")
		return

	if card_display == null:
		push_warning("CardMouseTiltRoot has no card_display assigned.")
		return

	card_viewport.size = Vector2i(card_size)
	card_viewport.transparent_bg = true
	card_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	card_display.texture = card_viewport.get_texture()
	card_display.centered = true

	start_scale = card_display.scale


func _setup_shader_material() -> void:
	if card_display == null:
		return

	if not card_display.material is ShaderMaterial:
		push_warning("CardDisplay does not have a ShaderMaterial.")
		return

	shader_material = card_display.material.duplicate()
	card_display.material = shader_material

	shader_material.set_shader_parameter("rect_size", card_size)
	shader_material.set_shader_parameter("x_rot", 0.0)
	shader_material.set_shader_parameter("y_rot", 0.0)


func _is_mouse_over_card() -> bool:
	var local_mouse: Vector2 = card_display.to_local(get_global_mouse_position())
	var half_size: Vector2 = card_size * 0.5

	return (
		local_mouse.x >= -half_size.x
		and local_mouse.x <= half_size.x
		and local_mouse.y >= -half_size.y
		and local_mouse.y <= half_size.y
	)


func _update_hover_tilt(delta: float) -> void:
	var local_mouse: Vector2 = card_display.to_local(get_global_mouse_position())
	var half_size: Vector2 = card_size * 0.5

	var x_percent: float = clampf(local_mouse.x / half_size.x, -1.0, 1.0)
	var y_percent: float = clampf(local_mouse.y / half_size.y, -1.0, 1.0)

	var target_y_rot: float = x_percent * max_y_rotation
	var target_x_rot: float = -y_percent * max_x_rotation

	_set_target_rotation(target_x_rot, target_y_rot, delta)
	_set_target_scale(start_scale * hover_scale, delta)


func _return_to_normal(delta: float) -> void:
	_set_target_rotation(0.0, 0.0, delta)
	_set_target_scale(start_scale, delta)


func _set_target_rotation(
	target_x_rot: float,
	target_y_rot: float,
	delta: float
) -> void:
	var lerp_weight: float = clampf(tilt_speed * delta, 0.0, 1.0)

	current_x_rot = lerpf(current_x_rot, target_x_rot, lerp_weight)
	current_y_rot = lerpf(current_y_rot, target_y_rot, lerp_weight)

	shader_material.set_shader_parameter("x_rot", current_x_rot)
	shader_material.set_shader_parameter("y_rot", current_y_rot)


func _set_target_scale(target_scale: Vector2, delta: float) -> void:
	if card_display == null:
		return

	var lerp_weight: float = clampf(scale_speed * delta, 0.0, 1.0)
	card_display.scale = card_display.scale.lerp(target_scale, lerp_weight)
