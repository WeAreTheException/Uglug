extends CanvasItem
class_name PlaceLiquidTimer

@export var place_timer: Timer
@export var phase_manager: Node
@export var turn_manager: Node

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

	if phase_manager != null and phase_manager.has_signal("phase_changed"):
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

	if not is_place_phase:
		visible = false


func _update_color() -> void:
	if shader_material == null:
		return

	if _is_host_turn():
		shader_material.set_shader_parameter("liquid_color", host_color)
	else:
		shader_material.set_shader_parameter("liquid_color", client_color)


func _is_host_turn() -> bool:
	if turn_manager == null:
		return true

	if turn_manager.has_method("is_host_turn"):
		return turn_manager.is_host_turn()

	var possible_values: Array[String] = [
		"current_turn_player",
		"current_player",
		"turn_player",
		"active_player",
		"current_turn"
	]

	for property_name: String in possible_values:
		var value = turn_manager.get(property_name)

		if value == null:
			continue

		var text: String = str(value).to_lower()

		if text == "host" or text == "player1" or text == "player_1" or text == "1":
			return true

		if text == "client" or text == "player2" or text == "player_2" or text == "2":
			return false

	return true
