extends Node
class_name CardDragHandler

var card_being_dragged: Node2D = null
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size

func update_drag() -> void:
	if card_being_dragged == null:
		return

	var mouse_pos = get_global_mouse_position()
	card_being_dragged.position = Vector2(
		clamp(mouse_pos.x, 0, screen_size.x),
		clamp(mouse_pos.y, 0, screen_size.y)
	)

func start_drag(card: Node2D) -> void:
	card_being_dragged = card
	card.scale = Vector2(1, 1)

func stop_drag() -> Node2D:
	var card := card_being_dragged

	if card:
		card.scale = Vector2(1.05, 1.05)

	card_being_dragged = null
	return card
