extends Node
class_name CameraShakeFeedback

@export var camera_target: Node2D
@export var values: CameraShakeValues

@export var test_key: Key = KEY_H
@export var enable_test_key: bool = true
@export var print_debug: bool = true

var original_position: Vector2 = Vector2.ZERO
var original_rotation: float = 0.0

var trauma: float = 0.0
var noise := FastNoiseLite.new()

var impact_offset: Vector2 = Vector2.ZERO
var impact_velocity: Vector2 = Vector2.ZERO
var impact_rotation: float = 0.0
var impact_rotation_velocity: float = 0.0


func _ready() -> void:
	if camera_target != null:
		original_position = camera_target.position
		original_rotation = camera_target.rotation

	if values != null:
		_setup_noise()


func _process(delta: float) -> void:
	if camera_target == null:
		return

	if values == null:
		return

	_update_impact_spring(delta)
	_update_trauma(delta)
	_apply_camera_motion()


func _unhandled_input(event: InputEvent) -> void:
	if not enable_test_key:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed:
		return

	if key_event.echo:
		return

	if key_event.keycode == test_key:
		play_hurt_shake()


func play_hurt_shake() -> void:
	if camera_target == null:
		_debug_print("Missing camera_target.")
		return

	if values == null:
		_debug_print("Missing values.")
		return

	if values.snap_back_before_new_trauma:
		impact_offset = Vector2.ZERO
		impact_velocity = Vector2.ZERO
		impact_rotation = 0.0
		impact_rotation_velocity = 0.0
		camera_target.position = original_position
		camera_target.rotation = original_rotation

	add_trauma(values.hurt_trauma_amount)

	impact_offset += values.hurt_impact_offset
	impact_velocity += values.hurt_impact_velocity
	impact_rotation += deg_to_rad(values.hurt_impact_rotation_degrees)
	impact_rotation_velocity += deg_to_rad(values.hurt_impact_rotation_velocity_degrees)


func add_trauma(amount: float) -> void:
	if values == null:
		return

	trauma = clamp(trauma + amount, 0.0, values.max_trauma)


func reset_camera_shake() -> void:
	trauma = 0.0
	impact_offset = Vector2.ZERO
	impact_velocity = Vector2.ZERO
	impact_rotation = 0.0
	impact_rotation_velocity = 0.0

	if camera_target != null:
		camera_target.position = original_position
		camera_target.rotation = original_rotation


func _update_impact_spring(delta: float) -> void:
	var acceleration: Vector2 = -impact_offset * values.spring_strength
	acceleration -= impact_velocity * values.damping

	impact_velocity += acceleration * delta
	impact_offset += impact_velocity * delta

	var rotation_acceleration: float = -impact_rotation * values.rotation_spring_strength
	rotation_acceleration -= impact_rotation_velocity * values.rotation_damping

	impact_rotation_velocity += rotation_acceleration * delta
	impact_rotation += impact_rotation_velocity * delta


func _update_trauma(delta: float) -> void:
	if trauma <= 0.0:
		trauma = 0.0
		return

	trauma = max(trauma - values.trauma_decay_per_second * delta, 0.0)


func _apply_camera_motion() -> void:
	var shake: float = pow(trauma, values.trauma_exponent)
	var t: float = Time.get_ticks_msec() / 1000.0
	var sample_time: float = t * values.noise_frequency

	var offset_x: float = noise.get_noise_2d(values.noise_seed, sample_time)
	var offset_y: float = noise.get_noise_2d(values.noise_seed + 100, sample_time)
	var rot_noise: float = noise.get_noise_2d(values.noise_seed + 200, sample_time)

	var noise_offset := Vector2(
		offset_x * values.max_offset.x * values.horizontal_multiplier * shake,
		offset_y * values.max_offset.y * values.vertical_multiplier * shake
	)

	var noise_rotation: float = deg_to_rad(
		rot_noise * values.max_rotation_degrees * values.rotation_multiplier * shake
	)

	camera_target.position = original_position + impact_offset + noise_offset
	camera_target.rotation = original_rotation + impact_rotation + noise_rotation


func _setup_noise() -> void:
	noise.seed = values.noise_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 1.0


func _debug_print(message: String) -> void:
	if not print_debug:
		return

	print("[CameraShakeFeedback] ", message)
