extends Node2D
class_name DominantSpriteHandler

@export var dominant: Dominant
@export var disabled_texture: Texture2D

@export_range(0.0, 1.0)
var inactive_opacity: float = 0.35

@onready var state_handler: DominantStateHandler = get_parent().get_node_or_null("DominantStateHandler")
@onready var sprite: Sprite2D = get_node_or_null("Sprite")

func _ready() -> void:
	if state_handler == null:
		print("DominantSpriteHandler blocked: DominantStateHandler not found")
		return

	if sprite == null:
		print("DominantSpriteHandler blocked: Sprite child not found")
		return

	if not state_handler.state_changed.is_connected(_on_state_changed):
		state_handler.state_changed.connect(_on_state_changed)

	_on_state_changed(state_handler.current_state)


func _on_state_changed(new_state: DominantStateHandler.DominantState) -> void:
	if sprite == null:
		return

	sprite.visible = true
	sprite.modulate.a = 1.0

	match new_state:
		DominantStateHandler.DominantState.DISABLED:
			if disabled_texture != null:
				sprite.texture = disabled_texture
			sprite.modulate.a = 1.0

		DominantStateHandler.DominantState.ACTIVE:
			if dominant != null and dominant.active_texture != null:
				sprite.texture = dominant.active_texture
			sprite.modulate.a = 1.0

		DominantStateHandler.DominantState.INACTIVE:
			if dominant != null and dominant.active_texture != null:
				sprite.texture = dominant.active_texture
			sprite.modulate.a = inactive_opacity

	print("DOMINANT SPRITE UPDATED")
