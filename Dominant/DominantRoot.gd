extends Node2D
class_name DominantRoot

@export var round_manager: RoundManager

@onready var state_handler: DominantStateHandler = $DominantStateHandler

func _ready() -> void:
	if round_manager == null:
		round_manager = _find_round_manager()

	if state_handler == null:
		state_handler = _find_state_handler()

	if state_handler == null:
		print("DominantRoot blocked: DominantStateHandler not found")
		return

	if round_manager == null:
		print("DominantRoot blocked: RoundManager not found")
		return

	if not round_manager.round_changed.is_connected(_on_round_changed):
		round_manager.round_changed.connect(_on_round_changed)

	_apply_round_state(round_manager.current_round)

func _on_round_changed(round_number: int) -> void:
	_apply_round_state(round_number)

func _apply_round_state(round_number: int) -> void:
	if round_number <= 1:
		state_handler.set_state(DominantStateHandler.DominantState.DISABLED)
	else:
		state_handler.set_state(DominantStateHandler.DominantState.ACTIVE)

func _find_round_manager() -> RoundManager:
	return _find_node_recursive(get_tree().current_scene, RoundManager) as RoundManager

func _find_state_handler() -> DominantStateHandler:
	return _find_node_recursive(self, DominantStateHandler) as DominantStateHandler

func _find_node_recursive(node: Node, target_type) -> Node:
	if node == null:
		return null

	if is_instance_of(node, target_type):
		return node

	for child in node.get_children():
		var found := _find_node_recursive(child, target_type)
		if found != null:
			return found

	return null
