extends Node
class_name RoundManager

@export var turn_manager: TurnManager

var current_round: int = 1
var last_seen_draw_phase := false

func _ready() -> void:
	if turn_manager == null:
		turn_manager = _find_turn_manager()

	if turn_manager != null:
		if not turn_manager.turn_player_changed.is_connected(_on_turn_player_changed):
			turn_manager.turn_player_changed.connect(_on_turn_player_changed)

	print("ROUND STARTED: ", current_round)

func _on_turn_player_changed(_client_id: int, phase_name: String) -> void:
	if phase_name == "Draw":
		if not last_seen_draw_phase:
			_print_round_changed()
		last_seen_draw_phase = true
	else:
		last_seen_draw_phase = false

func _print_round_changed() -> void:
	print("ROUND CHANGED TO: ", current_round)

func advance_round() -> void:
	current_round += 1
	print("ROUND CHANGED TO: ", current_round)

func _find_turn_manager() -> TurnManager:
	var found := get_tree().get_first_node_in_group("turn_manager")
	if found != null and found is TurnManager:
		return found

	return _find_turn_manager_recursive(get_tree().current_scene)

func _find_turn_manager_recursive(node: Node) -> TurnManager:
	if node == null:
		return null

	if node is TurnManager:
		return node

	for child in node.get_children():
		var result := _find_turn_manager_recursive(child)
		if result != null:
			return result

	return null
