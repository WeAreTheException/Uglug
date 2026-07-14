extends Node
class_name SlotPlayPhaseFeedback

@export var target: CanvasItem
@export var debug_toggle_key: Key = KEY_R
@export var enable_debug_toggle: bool = true

var slot_feedback: SlotFeedback = null
var is_active: bool = false


func setup(source_feedback: SlotFeedback) -> void:
	slot_feedback = source_feedback
	show_idle()


func _input(event: InputEvent) -> void:
	if not enable_debug_toggle:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == debug_toggle_key:
			set_active(not is_active)


func show_idle() -> void:
	set_active(false)


func show_playable() -> void:
	set_active(true)


func show_inactive() -> void:
	set_active(false)


func set_active(value: bool) -> void:
	is_active = value

	if target == null:
		return

	target.visible = value
