extends Node2D
class_name DominantSpriteHandler

@export var dominant: Dominant
@export var disabled_texture: Texture2D

@export_range(0.0, 1.0)
var inactive_opacity: float = 0.35

@onready var state_handler: DominantStateHandler = get_parent().get_node_or_null("DominantStateHandler")

@onready var disabled_sprite: Sprite2D = get_node_or_null("Disabled")
@onready var active_sprite: Sprite2D = get_node_or_null("Active")
@onready var inactive_sprite: Sprite2D = get_node_or_null("Inactive")

func _ready() -> void:
	if state_handler == null:
		print("DominantSpriteHandler blocked: DominantStateHandler not found")
		return

	if disabled_sprite == null:
		print("DominantSpriteHandler blocked: Disabled sprite not found")
		return

	if active_sprite == null:
		print("DominantSpriteHandler blocked: Active sprite not found")
		return

	if inactive_sprite == null:
		print("DominantSpriteHandler blocked: Inactive sprite not found")
		return

	if disabled_texture != null:
		disabled_sprite.texture = disabled_texture

	if dominant != null and dominant.active_texture != null:
		active_sprite.texture = dominant.active_texture
		inactive_sprite.texture = dominant.active_texture

	if not state_handler.state_changed.is_connected(_on_state_changed):
		state_handler.state_changed.connect(_on_state_changed)

	_on_state_changed(state_handler.current_state)

func _on_state_changed(new_state: DominantStateHandler.DominantState) -> void:
	disabled_sprite.visible = false
	active_sprite.visible = false
	inactive_sprite.visible = false

	match new_state:
		DominantStateHandler.DominantState.DISABLED:
			disabled_sprite.visible = true
			disabled_sprite.modulate.a = 1.0

		DominantStateHandler.DominantState.ACTIVE:
			active_sprite.visible = true
			active_sprite.modulate.a = 1.0

		DominantStateHandler.DominantState.INACTIVE:
			inactive_sprite.visible = true
			inactive_sprite.modulate.a = inactive_opacity

	print("DOMINANT SPRITE UPDATED")
