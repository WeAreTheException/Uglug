extends CanvasItem
class_name PlaceLiquidTimer

@export var place_timer: Timer
@export var phase_manager: PhaseManager

@export var host_color: Color = Color.RED
@export var client_color: Color = Color.GREEN

@export var hide_when_not_place_phase: bool = true

var is_place_phase: bool = false
var shader_material: ShaderMaterial = null


func _ready() -> void:
	visible = false

	if material is ShaderMaterial:
		shader_material = material.duplicate() as ShaderMaterial
		material = shader_material

	if phase_manager != null:
		phase_manager.phase_changed.connect(_on_phase_changed)

	_update_color()


func _process(_delta: float) -> void:
	if place_timer == null:
		return

	if hide_when_not_place_phase and not is_place_phase:
		visible = false
		return

	visible = true

	var fill_amount: float = 0.0

	if place_timer.wait_time > 0.0:
		fill_amount = place_timer.time_left / place_timer.wait_time

	fill_amount = clamp(fill_amount, 0.0, 1.0)

	if shader_material != null:
		shader_material.set_shader_parameter("fV", fill_amount)

	_update_color()


func _on_phase_changed(phase_name: String) -> void:
	is_place_phase = phase_name.to_lower() == "place"

	if is_place_phase:
		_update_color()
	else:
		visible = false


func _update_color() -> void:
	if shader_material == null:
		return

	if phase_manager == null:
		return

	var current_color: Color = phase_manager.timer_label.get_theme_color("font_color")

	print("CURRENT TIMER COLOR: ", current_color)

	if current_color == phase_manager.player_one_place_color:
		shader_material.set_shader_parameter("liquid_color", host_color)
	else:
		shader_material.set_shader_parameter("liquid_color", client_color)
