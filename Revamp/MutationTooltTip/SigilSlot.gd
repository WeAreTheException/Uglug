extends Node2D
class_name SigilSlot

@export var sprite: Sprite2D

# Kept so the existing CardVisuals scene does not need to be rebuilt.
# Sigil input is now always disabled because mutation tooltips come from card hover.
@export var input: SigilInput

@export var line_color_parameter: String = "line_color"
@export var line_thickness_parameter: String = "line_thickness"
@export var inactive_outline_color: Color = Color(0, 0, 0, 0)
@export var inactive_line_thickness: float = 0.0

var runtime: MutationRuntime = null
var mutation: Mutation = null

var greyed_out_alpha: float = 0.35
var unique_material: ShaderMaterial = null

var is_activation_flashing: bool = false
var activation_flash_version: int = 0


func _ready() -> void:
	_prepare_unique_material()
	_set_input_enabled(false)
	clear()


func setup_runtime(source_runtime: MutationRuntime, source_greyed_out_alpha: float) -> void:
	_disconnect_runtime()

	runtime = source_runtime
	mutation = null
	greyed_out_alpha = source_greyed_out_alpha

	if runtime != null:
		mutation = runtime.mutation

	if mutation == null:
		clear()
		return

	visible = true
	_prepare_unique_material()
	_connect_runtime()
	_set_input_enabled(false)

	if sprite != null:
		sprite.texture = mutation.sigil_texture
		sprite.visible = mutation.sigil_texture != null

	_apply_runtime_alpha()
	_apply_persistent_outline_state()


func clear() -> void:
	_disconnect_runtime()

	activation_flash_version += 1
	is_activation_flashing = false

	runtime = null
	mutation = null

	if sprite != null:
		sprite.texture = null
		sprite.visible = false
		sprite.modulate.a = 1.0

	_set_input_enabled(false)
	_apply_inactive_outline()
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


func _connect_runtime() -> void:
	if runtime == null:
		return

	if not runtime.visual_active_changed.is_connected(
		_on_runtime_visual_active_changed
	):
		runtime.visual_active_changed.connect(
			_on_runtime_visual_active_changed
		)

	if not runtime.visual_triggered.is_connected(
		_on_runtime_visual_triggered
	):
		runtime.visual_triggered.connect(
			_on_runtime_visual_triggered
		)

	if not runtime.runtime_state_changed.is_connected(
		_on_runtime_state_changed
	):
		runtime.runtime_state_changed.connect(
			_on_runtime_state_changed
		)


func _disconnect_runtime() -> void:
	if runtime == null:
		return

	if runtime.visual_active_changed.is_connected(
		_on_runtime_visual_active_changed
	):
		runtime.visual_active_changed.disconnect(
			_on_runtime_visual_active_changed
		)

	if runtime.visual_triggered.is_connected(
		_on_runtime_visual_triggered
	):
		runtime.visual_triggered.disconnect(
			_on_runtime_visual_triggered
		)

	if runtime.runtime_state_changed.is_connected(
		_on_runtime_state_changed
	):
		runtime.runtime_state_changed.disconnect(
			_on_runtime_state_changed
		)


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


func _on_runtime_visual_active_changed(
	source_runtime: MutationRuntime,
	_is_visual_active: bool
) -> void:
	if source_runtime != runtime:
		return

	if is_activation_flashing:
		return

	_apply_persistent_outline_state()


func _on_runtime_visual_triggered(
	source_runtime: MutationRuntime,
	duration: float
) -> void:
	if source_runtime != runtime:
		return

	_play_activation_flash(duration)


func _on_runtime_state_changed(
	source_runtime: MutationRuntime
) -> void:
	if source_runtime != runtime:
		return

	_apply_runtime_alpha()

	if not is_activation_flashing:
		_apply_persistent_outline_state()


func _play_activation_flash(duration: float) -> void:
	activation_flash_version += 1
	var this_flash_version := activation_flash_version

	is_activation_flashing = true
	_apply_active_outline()

	var tree := get_tree()

	if tree == null:
		_finish_activation_flash(this_flash_version)
		return

	var timer := tree.create_timer(maxf(duration, 0.01))
	timer.timeout.connect(
		func() -> void:
			_finish_activation_flash(this_flash_version)
	)


func _finish_activation_flash(flash_version: int) -> void:
	if flash_version != activation_flash_version:
		return

	is_activation_flashing = false
	_apply_persistent_outline_state()


func _apply_runtime_alpha() -> void:
	if sprite == null:
		return

	if runtime == null:
		sprite.modulate.a = 1.0
		return

	sprite.modulate.a = (
		greyed_out_alpha
		if runtime.is_greyed_out
		else 1.0
	)


func _apply_persistent_outline_state() -> void:
	if runtime != null and runtime.is_visual_active:
		_apply_active_outline()
		return

	_apply_inactive_outline()


func _apply_active_outline() -> void:
	if mutation == null:
		_apply_inactive_outline()
		return

	_set_outline_style(
		mutation.activation_outline_color,
		mutation.activation_outline_thickness
	)


func _apply_inactive_outline() -> void:
	_set_outline_style(
		inactive_outline_color,
		inactive_line_thickness
	)


func _set_outline_style(color: Color, thickness: float) -> void:
	if unique_material == null:
		_prepare_unique_material()

	if unique_material == null:
		return

	unique_material.set_shader_parameter(
		line_color_parameter,
		color
	)

	unique_material.set_shader_parameter(
		line_thickness_parameter,
		thickness
	)
