extends Area2D
class_name LobbyColonyIcon

signal lobby_clicked(lobby_info: Dictionary)

@export var name_label: Label
@export var player_icon: Sprite2D
@export var public_lobby_visual: CanvasItem
@export var private_lobby_visual: CanvasItem
@export var bounce_feedback: LobbyBounceFeedback
@export var lock_sprite: Sprite2D
@export var private_tooltip: Label

@export var hover_scale := 1.12
@export var hover_tween_time := 0.12
@export var click_ripple_scale := 1.28
@export var click_ripple_time := 0.18

var lobby_info: Dictionary = {}
var base_scale := Vector2.ONE
var feedback_tween: Tween
var is_private_lobby := false
var is_own_lobby := false


func _ready() -> void:
	input_pickable = true
	base_scale = scale

	_set_mouse_ignore(name_label)
	_set_mouse_ignore(player_icon)
	_set_mouse_ignore(public_lobby_visual)
	_set_mouse_ignore(private_lobby_visual)
	_set_mouse_ignore(lock_sprite)
	_set_mouse_ignore(private_tooltip)

	if private_tooltip != null:
		private_tooltip.visible = false

	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)

	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)

	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)


func setup(source_lobby_info: Dictionary) -> void:
	lobby_info = source_lobby_info

	var display_name: String = lobby_info.get("display_name", "Unknown")
	is_private_lobby = lobby_info.get("is_private", false)
	is_own_lobby = lobby_info.get("is_own_lobby", false)

	input_pickable = not is_own_lobby

	if name_label != null:
		name_label.text = display_name
		name_label.add_theme_color_override("font_outline_color", Color.BLACK)
		name_label.add_theme_constant_override("outline_size", 4)

	if is_private_lobby:
		_set_private_visual()
	else:
		_set_public_visual()

	if is_own_lobby:
		_disable_own_lobby_feedback()


func _on_mouse_entered() -> void:
	if is_own_lobby:
		return

	_tween_scale(base_scale * hover_scale)

	if is_private_lobby and private_tooltip != null:
		private_tooltip.visible = true


func _on_mouse_exited() -> void:
	if is_own_lobby:
		return

	_tween_scale(base_scale)

	if private_tooltip != null:
		private_tooltip.visible = false


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_own_lobby:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton

		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_play_click_ripple()
			lobby_clicked.emit(lobby_info)


func _play_click_ripple() -> void:
	if feedback_tween != null:
		feedback_tween.kill()

	feedback_tween = create_tween()
	feedback_tween.set_trans(Tween.TRANS_BACK)
	feedback_tween.set_ease(Tween.EASE_OUT)
	feedback_tween.tween_property(self, "scale", base_scale * click_ripple_scale, click_ripple_time)
	feedback_tween.tween_property(self, "scale", base_scale * hover_scale, click_ripple_time)


func _tween_scale(target_scale: Vector2) -> void:
	if feedback_tween != null:
		feedback_tween.kill()

	feedback_tween = create_tween()
	feedback_tween.set_trans(Tween.TRANS_SINE)
	feedback_tween.set_ease(Tween.EASE_OUT)
	feedback_tween.tween_property(self, "scale", target_scale, hover_tween_time)


func _set_public_visual() -> void:
	if bounce_feedback != null:
		bounce_feedback.start_bounce()

	if public_lobby_visual != null:
		public_lobby_visual.visible = true
		public_lobby_visual.modulate = Color.WHITE

	if private_lobby_visual != null:
		private_lobby_visual.visible = false

	if lock_sprite != null:
		lock_sprite.visible = false

	if private_tooltip != null:
		private_tooltip.visible = false


func _set_private_visual() -> void:
	if bounce_feedback != null:
		bounce_feedback.stop_bounce()

	if public_lobby_visual != null:
		public_lobby_visual.visible = false

	if private_lobby_visual != null:
		private_lobby_visual.visible = true
		private_lobby_visual.modulate = Color.WHITE

	if lock_sprite != null:
		lock_sprite.visible = true

	if private_tooltip != null:
		private_tooltip.visible = false


func _disable_own_lobby_feedback() -> void:
	if feedback_tween != null:
		feedback_tween.kill()
		feedback_tween = null

	scale = base_scale

	if bounce_feedback != null:
		bounce_feedback.stop_bounce()

	if private_tooltip != null:
		private_tooltip.visible = false


func _set_mouse_ignore(node: Node) -> void:
	if node == null:
		return

	if node is Control:
		var control := node as Control
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for child in node.get_children():
		_set_mouse_ignore(child)
