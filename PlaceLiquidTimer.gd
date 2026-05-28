extends CanvasItem
class_name PlaceLiquidTimer

@export var place_timer: Timer
@export var phase_manager: PhaseManager
@export var turn_manager: TurnManager

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

	if turn_manager != null:
		turn_manager.turn_player_changed.connect(_on_turn_player_changed)

	_update_color_from_current_placing_player()


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


func _on_phase_changed(phase_name: String) -> void:
	is_place_phase = phase_name.to_lower() == "place"

	if is_place_phase:
		_update_color_from_current_placing_player()
	else:
		visible = false


func _on_turn_player_changed(client_id: int, phase_name: String) -> void:
	if phase_name.to_lower() != "place":
		return

	_update_color_from_client_id(client_id)


func _update_color_from_current_placing_player() -> void:
	if turn_manager == null:
		return

	_update_color_from_client_id(turn_manager.current_placing_player_id)


func _update_color_from_client_id(client_id: int) -> void:
	if shader_material == null:
		return

	if turn_manager == null:
		shader_material.set_shader_parameter("liquid_color", host_color)
		return

	if client_id == turn_manager.player_one_id:
		shader_material.set_shader_parameter("liquid_color", host_color)
	else:
		shader_material.set_shader_parameter("liquid_color", client_color)
