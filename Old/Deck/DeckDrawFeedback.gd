extends Node
class_name DeckDrawFeedback

@export var card_draw_speed: float = 0.4
@export var flip_animation_name: String = "card_flip"

@export var draw_sfx: AudioStream
@export var volume_db: float = 0.0
@export var sfx_bus_name: String = "SFX"

@export_group("Draw Phase Feedback")
@export var hover_area: Area2D
@export var glow_visual: Sprite2D
@export var scale_target: Node2D
@export var max_draw_limit_label: Label

@export var normal_scale: Vector2 = Vector2.ONE
@export var hover_scale: Vector2 = Vector2(1.08, 1.08)
@export var tween_time: float = 0.08

@export var draw_phase_glow: float = 0.8
@export var hover_glow: float = 2.0
@export var glow_color: Color = Color(1.0, 0.85, 0.25, 1.0)

@export var pulse_speed: float = 4.0
@export var pulse_amount: float = 0.25
@export var shimmer_speed_x: float = 1.5
@export var shimmer_speed_y: float = 1.1
@export var shimmer_amount_x: float = 0.35
@export var shimmer_amount_y: float = 0.25

var phase_manager: PhaseManager = null
var draw_limit_handler: DeckDrawLimitHandler = null

var audio_player: AudioStreamPlayer
var is_draw_phase := false
var is_hovered := false
var last_can_draw := true

var tween: Tween
var glow_tween: Tween
var max_draw_message_tween: Tween


func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = volume_db
	audio_player.bus = sfx_bus_name

	if scale_target == null:
		scale_target = glow_visual

	if max_draw_limit_label == null:
		max_draw_limit_label = get_tree().get_first_node_in_group("max_draw_limit_label") as Label

	if max_draw_limit_label != null:
		max_draw_limit_label.visible = false
		max_draw_limit_label.modulate.a = 1.0

	if hover_area != null:
		hover_area.mouse_entered.connect(_on_hover_entered)
		hover_area.mouse_exited.connect(_on_hover_exited)

	_setup_shader()


func _process(_delta: float) -> void:
	_try_connect_phase_manager()
	_update_shader_mouse_position()
	_update_idle_feedback()

	var can_draw_now := _can_draw_now()

	if is_draw_phase and last_can_draw and not can_draw_now:
		show_max_draw_limit_message()

	last_can_draw = can_draw_now

	if is_draw_phase:
		_update_feedback()


func _setup_shader() -> void:
	var mat := _get_shader_material()
	if mat == null:
		return

	if glow_visual != null and glow_visual.texture != null:
		mat.set_shader_parameter("size", glow_visual.texture.get_size())

	mat.set_shader_parameter("center1", Vector2(0.5, 0.5))
	mat.set_shader_parameter("center2", Vector2(0.5, 0.5))
	mat.set_shader_parameter("time1", 1.0)
	mat.set_shader_parameter("time2", 0.0)
	mat.set_shader_parameter("glow", 0.0)
	mat.set_shader_parameter("color", glow_color)


func _try_connect_phase_manager() -> void:
	if phase_manager == null:
		return

	if phase_manager.phase_changed.is_connected(_on_phase_changed):
		return

	phase_manager.phase_changed.connect(_on_phase_changed)


func prepare_card_start_position(card: Node2D, deck_root: Node2D) -> void:
	if card == null:
		return

	if deck_root == null:
		return

	card.global_position = deck_root.global_position


func add_card_to_hand_with_animation(target_hand: Node2D, card: Node2D) -> void:
	if target_hand == null:
		return

	if card == null:
		return

	if not target_hand.has_method("add_card_to_hand"):
		print("draw animation blocked: target_hand missing add_card_to_hand")
		return

	target_hand.add_card_to_hand(card, card_draw_speed)


func play_draw_animation(card: Node) -> void:
	if card == null:
		return

	_play_sfx(draw_sfx)

	var animation_player := card.get_node_or_null("AnimationPlayer") as AnimationPlayer

	if animation_player == null:
		return

	if not animation_player.has_animation(flip_animation_name):
		return

	animation_player.play(flip_animation_name)


func _on_phase_changed(phase_name: String) -> void:
	is_draw_phase = phase_name.to_lower() == "draw"
	last_can_draw = _can_draw_now()
	_update_feedback()


func _on_hover_entered() -> void:
	is_hovered = true
	_update_feedback()


func _on_hover_exited() -> void:
	is_hovered = false
	_update_feedback()


func _can_draw_now() -> bool:
	if draw_limit_handler == null:
		return true

	return draw_limit_handler.can_draw()


func _update_feedback() -> void:
	var can_show_draw_feedback := is_draw_phase and _can_draw_now()

	var target_scale := normal_scale
	var target_glow := 0.0
	var target_time2 := 0.0

	if can_show_draw_feedback:
		target_glow = draw_phase_glow
		target_time2 = 0.35

	if can_show_draw_feedback and is_hovered:
		target_scale = hover_scale
		target_glow = hover_glow
		target_time2 = 0.35

	_tween_visual_scale(target_scale)
	_tween_shader_feedback(target_glow, target_time2)


func _update_shader_mouse_position() -> void:
	if not is_hovered:
		return

	if not _can_draw_now():
		return

	if glow_visual == null:
		return

	var mat := _get_shader_material()
	if mat == null:
		return

	if glow_visual.texture == null:
		return

	var local_mouse := glow_visual.to_local(glow_visual.get_global_mouse_position())
	var texture_size := glow_visual.texture.get_size()
	var uv := (local_mouse / texture_size) + Vector2(0.5, 0.5)

	mat.set_shader_parameter("center2", uv)


func _update_idle_feedback() -> void:
	if not is_draw_phase:
		return

	if not _can_draw_now():
		_tween_shader_feedback(0.0, 0.0)
		_tween_visual_scale(normal_scale)
		return

	if is_hovered:
		return

	var mat := _get_shader_material()
	if mat == null:
		return

	var time := Time.get_ticks_msec() / 1000.0

	var pulse := sin(time * pulse_speed) * pulse_amount
	mat.set_shader_parameter("glow", draw_phase_glow + pulse)

	var x := 0.5 + sin(time * shimmer_speed_x) * shimmer_amount_x
	var y := 0.5 + cos(time * shimmer_speed_y) * shimmer_amount_y

	mat.set_shader_parameter("center2", Vector2(x, y))
	mat.set_shader_parameter("time2", 0.35)


func show_max_draw_limit_message() -> void:
	if max_draw_limit_label == null:
		return

	if max_draw_message_tween != null:
		max_draw_message_tween.kill()

	max_draw_limit_label.text = "Max draw limit reached"
	max_draw_limit_label.visible = true
	max_draw_limit_label.modulate.a = 1.0

	max_draw_message_tween = create_tween()
	max_draw_message_tween.tween_interval(0.8)
	max_draw_message_tween.tween_property(max_draw_limit_label, "modulate:a", 0.0, 0.25)
	max_draw_message_tween.tween_callback(func(): max_draw_limit_label.visible = false)


func _tween_visual_scale(target_scale: Vector2) -> void:
	if scale_target == null:
		return

	if tween != null:
		tween.kill()

	tween = create_tween()
	tween.tween_property(scale_target, "scale", target_scale, tween_time)


func _tween_shader_feedback(target_glow: float, target_time2: float) -> void:
	var mat := _get_shader_material()
	if mat == null:
		return

	if glow_tween != null:
		glow_tween.kill()

	glow_tween = create_tween()
	glow_tween.parallel().tween_property(mat, "shader_parameter/glow", target_glow, 0.2)
	glow_tween.parallel().tween_property(mat, "shader_parameter/time2", target_time2, 0.2)


func _get_shader_material() -> ShaderMaterial:
	if glow_visual == null:
		return null

	return glow_visual.material as ShaderMaterial


func _play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return

	audio_player.stream = stream
	audio_player.play()
