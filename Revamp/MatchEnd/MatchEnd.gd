extends Control
class_name MatchEndScreen


signal rematch_pressed


@export_group("References")
@export var spiral_fade: ColorRect
@export var rematch_button: BaseButton
@export var quit_button: BaseButton

@export_group("Rematch")
@export var waiting_text: String = "WAITING..."

@export_group("Animation")
@export var spiral_fade_duration: float = 0.8
@export var button_fade_duration: float = 0.2
@export var button_reveal_delay: float = 0.08

@export_group("Debug")
@export var enable_debug_key: bool = true
@export var debug_show_key: Key = KEY_KP_9
@export var print_debug: bool = true


var spiral_material: ShaderMaterial = null
var active_tween: Tween = null

var is_end_screen_active: bool = false
var rematch_requested: bool = false

var original_rematch_text: String = ""


func _ready() -> void:
	if spiral_fade != null:
		spiral_material = (
			spiral_fade.material as ShaderMaterial
		)

		spiral_fade.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

	if rematch_button != null:
		original_rematch_text = rematch_button.text

		if not rematch_button.pressed.is_connected(
			_on_rematch_pressed
		):
			rematch_button.pressed.connect(
				_on_rematch_pressed
			)

	if quit_button != null:
		if not quit_button.pressed.is_connected(
			_on_quit_pressed
		):
			quit_button.pressed.connect(
				_on_quit_pressed
			)

	mouse_filter = Control.MOUSE_FILTER_STOP

	_reset_visual_state()


func _input(event: InputEvent) -> void:
	if not enable_debug_key:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed:
		return

	if key_event.echo:
		return

	if key_event.keycode != debug_show_key:
		return

	show_end_screen()


func show_end_screen() -> void:
	if is_end_screen_active:
		return

	is_end_screen_active = true
	rematch_requested = false

	_kill_active_tween()

	visible = true

	_set_spiral_progress(0.0)
	_prepare_buttons_for_reveal()
	_reset_rematch_button()

	if print_debug:
		print("END SCREEN: SHOWING")

	active_tween = create_tween()

	active_tween.tween_method(
		_set_spiral_progress,
		0.0,
		1.0,
		spiral_fade_duration
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	active_tween.tween_interval(
		button_reveal_delay
	)

	active_tween.tween_callback(
		_reveal_buttons
	)


func hide_end_screen() -> void:
	if not is_end_screen_active:
		return

	is_end_screen_active = false

	_kill_active_tween()
	_hide_buttons()

	_set_spiral_progress(1.0)

	active_tween = create_tween()

	active_tween.tween_method(
		_set_spiral_progress,
		1.0,
		0.0,
		spiral_fade_duration
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	active_tween.tween_callback(
		_finish_hiding
	)


func _prepare_buttons_for_reveal() -> void:
	if rematch_button != null:
		rematch_button.visible = false
		rematch_button.disabled = true

		_set_button_alpha(
			rematch_button,
			0.0
		)

	if quit_button != null:
		quit_button.visible = false
		quit_button.disabled = true

		_set_button_alpha(
			quit_button,
			0.0
		)


func _reveal_buttons() -> void:
	if not is_end_screen_active:
		return

	if rematch_button != null:
		rematch_button.visible = true
		rematch_button.disabled = false

		_set_button_alpha(
			rematch_button,
			0.0
		)

	if quit_button != null:
		quit_button.visible = true
		quit_button.disabled = false

		_set_button_alpha(
			quit_button,
			0.0
		)

	active_tween = create_tween()
	active_tween.set_parallel(true)

	if rematch_button != null:
		active_tween.tween_property(
			rematch_button,
			"modulate:a",
			1.0,
			button_fade_duration
		)

	if quit_button != null:
		active_tween.tween_property(
			quit_button,
			"modulate:a",
			1.0,
			button_fade_duration
		)


func _on_rematch_pressed() -> void:
	if rematch_requested:
		return

	rematch_requested = true

	if rematch_button != null:
		rematch_button.text = waiting_text
		rematch_button.disabled = true

	if print_debug:
		print("END SCREEN: REMATCH PRESSED")
		print("END SCREEN: WAITING FOR OPPONENT")

	rematch_pressed.emit()


func _on_quit_pressed() -> void:
	if print_debug:
		print("END SCREEN: QUIT PRESSED")

	get_tree().quit()


func reset_rematch_state() -> void:
	rematch_requested = false
	_reset_rematch_button()


func _reset_rematch_button() -> void:
	if rematch_button == null:
		return

	rematch_button.text = original_rematch_text

	if is_end_screen_active:
		rematch_button.disabled = false


func _hide_buttons() -> void:
	if rematch_button != null:
		rematch_button.visible = false
		rematch_button.disabled = true

	if quit_button != null:
		quit_button.visible = false
		quit_button.disabled = true


func _finish_hiding() -> void:
	visible = false
	rematch_requested = false

	_reset_rematch_button()

	if print_debug:
		print("END SCREEN: HIDDEN")


func _set_spiral_progress(value: float) -> void:
	if spiral_material == null:
		return

	spiral_material.set_shader_parameter(
		"progress",
		value
	)


func _set_button_alpha(
	button: CanvasItem,
	alpha: float
) -> void:
	if button == null:
		return

	var color := button.modulate
	color.a = alpha
	button.modulate = color


func _reset_visual_state() -> void:
	_kill_active_tween()

	is_end_screen_active = false
	rematch_requested = false

	_set_spiral_progress(0.0)
	_hide_buttons()
	_reset_rematch_button()

	visible = false


func _kill_active_tween() -> void:
	if active_tween == null:
		return

	if active_tween.is_valid():
		active_tween.kill()

	active_tween = null
