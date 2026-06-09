extends Area2D
class_name CardInput

signal hovered
signal unhovered
signal left_pressed
signal right_pressed

var card: CardRoot = null
var is_hovered: bool = false

func setup(source_card: CardRoot) -> void:
	card = source_card

func _ready() -> void:
	input_pickable = true
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is not InputEventMouseButton:
		return
	if not event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		left_pressed.emit()
	if event.button_index == MOUSE_BUTTON_RIGHT:
		right_pressed.emit()

func _on_mouse_entered() -> void:
	is_hovered = true
	hovered.emit()
	if card != null:
		card.hovered.emit(card)

func _on_mouse_exited() -> void:
	is_hovered = false
	unhovered.emit()
	if card != null:
		card.unhovered.emit(card)
