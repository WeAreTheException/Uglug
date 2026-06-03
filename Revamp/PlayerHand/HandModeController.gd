extends Node
class_name HandModeController

@export var hand: PlayerHandRoot
@export var hand_layout: HandLayout
@export var hand_drag_controller: HandDragController

var current_mode: PhaseManager.HandMode = PhaseManager.HandMode.HAND_PASSIVE


func _ready() -> void:
	if hand == null:
		hand = get_parent() as PlayerHandRoot

	if hand != null:
		if hand_layout == null:
			hand_layout = hand.hand_layout


func set_hand_mode(mode: PhaseManager.HandMode) -> void:
	current_mode = mode

	if hand_layout != null:
		hand_layout.set_hand_mode(mode)

	if hand_drag_controller != null:
		hand_drag_controller.set_drag_enabled(
			mode == PhaseManager.HandMode.HAND_PASSIVE
	)
