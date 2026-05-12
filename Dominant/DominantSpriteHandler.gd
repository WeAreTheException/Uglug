extends Node
class_name DominantSpriteHandler

@export var state_handler: DominantStateHandler

@onready var disabled_sprite: Node2D = $Disabled
@onready var active_sprite: Node2D = $Active
@onready var inactive_sprite: Node2D = $Inactive

func _ready() -> void:
	if state_handler == null:
		state_handler = get_parent().get_node_or_null("DominantStateHandler") as DominantStateHandler

	if state_handler != null:
		if not state_handler.state_changed.is_connected(_on_state_changed):
			state_handler.state_changed.connect(_on_state_changed)

		_on_state_changed(state_handler.get_state_name())
	else:
		print("DominantSpriteHandler blocked: DominantStateHandler not found")

func _on_state_changed(state_name: String) -> void:
	disabled_sprite.visible = state_name == "Disabled"
	active_sprite.visible = state_name == "Active"
	inactive_sprite.visible = state_name == "Inactive"

	print("DOMINANT SPRITE SET TO: ", state_name)
