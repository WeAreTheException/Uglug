extends Node
class_name SlotPlacementPreviewFeedback

@export var normal_sprite: CanvasItem
@export var playable_shader_sprite: CanvasItem

@export var preview_color: Color = Color(1.0, 0.85, 0.25, 1.0)
@export var idle_color: Color = Color.WHITE

@export var force_color_parameter: String = "force_color"
@export var force_amount_parameter: String = "force_amount"

var slot_feedback: SlotFeedback = null
var is_previewed: bool = false
var playable_material: ShaderMaterial = null


func setup(source_feedback: SlotFeedback) -> void:
	slot_feedback = source_feedback
	_make_unique_material()
	set_previewed(false)


func set_previewed(value: bool) -> void:
	is_previewed = value

	if is_previewed:
		_apply_color(preview_color, 1.0)
	else:
		_apply_color(idle_color, 0.0)


func _make_unique_material() -> void:
	if playable_shader_sprite == null:
		return

	var shader_material := playable_shader_sprite.material as ShaderMaterial

	if shader_material == null:
		return

	playable_material = shader_material.duplicate() as ShaderMaterial
	playable_shader_sprite.material = playable_material


func _apply_color(color: Color, amount: float) -> void:
	if normal_sprite != null:
		normal_sprite.modulate = color if amount > 0.0 else idle_color

	if playable_material != null:
		playable_material.set_shader_parameter(force_color_parameter, color)
		playable_material.set_shader_parameter(force_amount_parameter, amount)
