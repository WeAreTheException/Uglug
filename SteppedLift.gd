extends Node2D

@export var enabled: bool = true

@export_group("Step Float")
@export var float_height: float = 12.0
@export var time_to_go_up: float = 0.15
@export var time_to_go_down: float = 0.15
@export var pause_between_sprites: float = 0.04

@export_group("Step Scale")
@export var scale_amount: float = 0.08

@export_group("Setup")
@export var auto_start: bool = true
@export var loop: bool = true
@export_range(1, 4) var max_sprites: int = 4

var sprites: Array[Node2D] = []
var start_positions: Array[Vector2] = []
var start_scales: Array[Vector2] = []

var current_index: int = 0
var is_running: bool = false


func _ready() -> void:
	_collect_sprites()

	if auto_start:
		start_sequence()


func _collect_sprites() -> void:
	sprites.clear()
	start_positions.clear()
	start_scales.clear()

	for child in get_children():
		if sprites.size() >= max_sprites:
			break

		if child is Node2D:
			sprites.append(child)
			start_positions.append(child.position)
			start_scales.append(child.scale)


func start_sequence() -> void:
	if is_running:
		return

	if sprites.is_empty():
		return

	is_running = true
	current_index = 0
	_run_sequence()


func stop_sequence() -> void:
	is_running = false
	_reset_all_sprites()


func _run_sequence() -> void:
	while is_running and enabled:
		if current_index >= sprites.size():
			if loop:
				current_index = 0
			else:
				is_running = false
				return

		await _float_sprite(current_index)

		current_index += 1

		if pause_between_sprites > 0.0:
			await get_tree().create_timer(pause_between_sprites).timeout


func _float_sprite(index: int) -> void:
	if index < 0 or index >= sprites.size():
		return

	var sprite := sprites[index]
	var start_position := start_positions[index]
	var start_scale := start_scales[index]

	var up_position := start_position + Vector2(0.0, -float_height)
	var bigger_scale := start_scale * (1.0 + scale_amount)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		sprite,
		"position",
		up_position,
		time_to_go_up
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		sprite,
		"scale",
		bigger_scale,
		time_to_go_up
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.chain()

	tween.tween_property(
		sprite,
		"position",
		start_position,
		time_to_go_down
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.tween_property(
		sprite,
		"scale",
		start_scale,
		time_to_go_down
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished


func _reset_all_sprites() -> void:
	for i in sprites.size():
		sprites[i].position = start_positions[i]
		sprites[i].scale = start_scales[i]
