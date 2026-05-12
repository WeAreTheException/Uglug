extends Node
class_name DominantSpriteHandler

@export var state_handler: DominantStateHandler
@export var dominant: Dominant
@export var disabled_texture: Texture2D

@export_range(0.0, 1.0)
var inactive_opacity: float = 0.35

var sprite: Sprite2D = null

func _ready() -> void:
	sprite = _find_sprite_recursive(self)

	if sprite == null:
		print("DominantSpriteHandler blocked: Sprite2D not found under: ", name)
		return

	print("DominantSpriteHandler using sprite: ", sprite.name)

	if state_handler == null:
		state_handler = _find_state_handler_recursive(self)

	if state_handler == null:
		print("DominantSpriteHandler blocked: DominantStateHandler not found")
		return

	if not state_handler.state_changed.is_connected(_on_state_changed):
		state_handler.state_changed.connect(_on_state_changed)

	_on_state_changed(state_handler.current_state)

func _on_state_changed(new_state: DominantStateHandler.DominantState) -> void:
	if sprite == null:
		return

	match new_state:
		DominantStateHandler.DominantState.DISABLED:
			sprite.visible = true
			sprite.modulate.a = 1.0

			if disabled_texture != null:
				sprite.texture = disabled_texture

		DominantStateHandler.DominantState.ACTIVE:
			sprite.visible = true
			sprite.modulate.a = 1.0

			if dominant != null and dominant.active_texture != null:
				sprite.texture = dominant.active_texture

		DominantStateHandler.DominantState.INACTIVE:
			sprite.visible = true
			sprite.modulate.a = inactive_opacity

			if dominant != null and dominant.active_texture != null:
				sprite.texture = dominant.active_texture

	print("DOMINANT SPRITE UPDATED")

func _find_sprite_recursive(node: Node) -> Sprite2D:
	if node is Sprite2D:
		return node

	for child in node.get_children():
		var found := _find_sprite_recursive(child)
		if found != null:
			return found

	return null

func _find_state_handler_recursive(node: Node) -> DominantStateHandler:
	if node is DominantStateHandler:
		return node

	for child in node.get_children():
		var found := _find_state_handler_recursive(child)
		if found != null:
			return found

	return null
